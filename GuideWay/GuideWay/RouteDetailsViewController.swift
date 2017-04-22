//
//  RouteDetailsViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/24/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

class RouteDetailsViewController: ASViewController<ASDisplayNode> {
    let presentationManager: PresentationManager
    let authManager: AuthManager
    let databaseManager: DatabaseManager
    let routeDetailsDisplayNode: RouteDetailsDisplayNode
    var route: Route

    var disposeBag = DisposeBag()
    let googleServicesAPI: GoogleServicesAPI

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    lazy var moreBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: #imageLiteral(resourceName: "ic_more"), 
            style: .plain, 
            target: self, 
            action: #selector(RouteDetailsViewController.moreButtonTapped)
        )
    }()

    lazy var editBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: #imageLiteral(resourceName: "ic_bar_edit"), 
            style: .plain, 
            target: self, 
            action: #selector(RouteDetailsViewController.editButtonTapped)
        )
    }()

    lazy var editCancelBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: #imageLiteral(resourceName: "ic_close"), 
            style: .plain, 
            target: self, 
            action: #selector(RouteDetailsViewController.editCancelButtonTapped)
        )
    }()

    lazy var editConfirmBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: #imageLiteral(resourceName: "ic_checkmark"),
            style: .plain,
            target: self,
            action: #selector(RouteDetailsViewController.editConfirmButtonTapped)
        )
    }()

    var onRouteDelete: (() -> ())?

    init(presentationManager: PresentationManager,
         authManager: AuthManager,
         databaseManager: DatabaseManager,
         route: Route,
         googleServicesAPI: GoogleServicesAPI) {
        self.presentationManager = presentationManager
        self.authManager = authManager
        self.databaseManager = databaseManager
        self.routeDetailsDisplayNode =
            presentationManager.getRouteDetailsDisplayNode(
                with: route.directions == nil ? .loading : .loaded(route))
        self.route = route
        self.googleServicesAPI = googleServicesAPI
        super.init(node: routeDetailsDisplayNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        routeDetailsDisplayNode.onPracticeTap = { [unowned self] in
            self.present(
                self.presentationManager
                    .getRouteMapViewController(
                        with: self.route,
                        mode: .practice
                ),
                animated: true,
                completion: nil
            )
        }
        routeDetailsDisplayNode.onTestTap = { [unowned self] in
            let routeMapViewController = self.presentationManager
                .getRouteMapViewController(
                    with: self.route,
                    mode: .testing
            )

            routeMapViewController.onTestingFinished = { [unowned self] route in
                guard self.authManager.isLoggedIn else {
                    self.route = route
                    self.routeDetailsDisplayNode.state = .loaded(self.route)
                    self.routeDetailsDisplayNode.collectionNode.reloadData()
                    return
                }
                self.databaseManager.updateRoute(route)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { [weak self] _ in
                        guard let strongSelf = self else {
                            return
                        }

                        strongSelf.route = route
                        strongSelf.routeDetailsDisplayNode.state = .loaded(strongSelf.route)
                        strongSelf.routeDetailsDisplayNode.collectionNode.reloadData()
                    }, onError: { [weak self] _ in
                        guard let strongSelf = self else {
                            return
                        }

                        InformerNode.showInformer(
                            for: strongSelf.node, 
                            with: NSLocalizedString("informer.network_error", comment: "")
                        )
                    })
                    .addDisposableTo(self.disposeBag)
            }
            self.present(
                routeMapViewController,
                animated: true,
                completion: nil
            )
        }
        routeDetailsDisplayNode.onShowPassDetailsTap = { [unowned self] route, passIndex in
            let vc = self.presentationManager
                .getRouteManeuversListViewController(
                    with: route, 
                    passIndex: passIndex
            )

            self.navigationController?.pushViewController(vc, animated: true)
        }
        navigationItem.title = NSLocalizedString(
            "route_details.title",
            comment: ""
        )
        navigationItem.rightBarButtonItems = []
        edgesForExtendedLayout = []
        routeDetailsDisplayNode.collectionNode.view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, 
                action: #selector(RouteDetailsViewController.hideKeyboard)
            )
        )
        if route.directions == nil {
            requestRouteDirections()
        } else {
            navigationItem.rightBarButtonItems = authManager.isLoggedIn
                ? [moreBarButton]
                : [editBarButton]
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar
            .barTintColor = UIColor(hexString: "626466")
        navigationController?.navigationBar
            .titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        navigationController?.setNavigationBarHidden(
            false,
            animated: true
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideKeyboard()
    }

    func requestRouteDirections() {
        disposeBag = DisposeBag()
        googleServicesAPI.requestDirections(
            from: route.origin, 
            to: route.destination
        )
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.route.directions = response.routes.first

                guard let _ = strongSelf.route.directions else {
                    strongSelf.navigationItem.setRightBarButtonItems([], animated: true)
                    strongSelf.routeDetailsDisplayNode.state = .noDirections
                    return
                }

                if strongSelf.authManager.isLoggedIn {
                    strongSelf.databaseManager.addRoute(
                        strongSelf.route, 
                        ownerId: strongSelf.authManager.currentUserId)
                        .observeOn(MainScheduler.instance)
                        .subscribe(onNext: { [weak strongSelf] route in
                            guard let strongSelf = strongSelf else {
                                return
                            }

                            strongSelf.route = route
                            strongSelf.navigationItem.setRightBarButtonItems(
                                [strongSelf.editBarButton],
                                animated: true
                            )
                            strongSelf.routeDetailsDisplayNode.state = .loaded(strongSelf.route)
                            if let navVc = strongSelf.navigationController,
                                navVc.viewControllers.count > 2,
                                navVc.viewControllers[navVc.viewControllers.count - 2] is RouteSetupViewController {
                                navVc.viewControllers.remove(at: navVc.viewControllers.count - 2)
                            }
                            InformerNode.showInformer(
                                for: strongSelf.node, 
                                with: NSLocalizedString("route_was_saved_to_list", comment: ""),
                                informerColor: "21C064"
                            )
                            }, onError: { [weak strongSelf] _ in
                                guard let strongSelf = strongSelf else {
                                    return
                                }

                                strongSelf.navigationItem.setRightBarButtonItems([], animated: true)
                                strongSelf.routeDetailsDisplayNode.state = .loadingFailed
                                InformerNode.showInformer(
                                    for: strongSelf.node, 
                                    with: NSLocalizedString("informer.network_error", comment: "")
                                )
                        })
                        .addDisposableTo(strongSelf.disposeBag)
                } else {
                    strongSelf.navigationItem.setRightBarButtonItems(
                        [strongSelf.editBarButton],
                        animated: true
                    )
                    strongSelf.routeDetailsDisplayNode.state = .loaded(strongSelf.route)
                }
            }, onError: { [weak self] error in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.navigationItem.setRightBarButtonItems([], animated: true)
                strongSelf.routeDetailsDisplayNode.state = .loadingFailed
            })
            .addDisposableTo(disposeBag)
    }

    func moreButtonTapped() {
        let alert = UIAlertController(
            title: nil, 
            message: nil, 
            preferredStyle: .actionSheet
        )
        let renameRouteAction = UIAlertAction(
            title: NSLocalizedString("route_details.rename_route", comment: ""), 
            style: .default, 
            handler: { _ in
                self.editButtonTapped()
        })
        let deleteRouteAction = UIAlertAction(
            title: NSLocalizedString("route_details.delete_route", comment: ""), 
            style: .destructive, 
            handler: { _ in
                self.deleteRoute()
        })
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel", comment: ""), 
            style: .cancel, 
            handler: nil
        )

        alert.addAction(renameRouteAction)
        alert.addAction(deleteRouteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    func editButtonTapped() {
        routeDetailsDisplayNode.collectionNode.view
            .setContentOffset(.zero, animated: true)
        navigationItem.setRightBarButtonItems(
            [editConfirmBarButton, editCancelBarButton], 
            animated: true
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { 
            self.routeDetailsDisplayNode.isEditing = true
        }
    }

    func deleteRoute() {
        databaseManager.deleteRoute(
            with: route.id!, 
            ownerId: authManager.currentUserId
        )
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.onRouteDelete?()
                strongSelf.navigationController?.popViewController(animated: true)
            }, onError: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                InformerNode.showInformer(
                    for: strongSelf.node, 
                    with: "informer.network_error"
                )
            })
            .addDisposableTo(disposeBag)
    }

    func editCancelButtonTapped() {
        routeDetailsDisplayNode.isEditing = false
        navigationItem.setRightBarButtonItems(
            authManager.isLoggedIn ? [moreBarButton] : [editBarButton],
            animated: true
        )
    }

    func editConfirmButtonTapped() {
        guard self.authManager.isLoggedIn else {
            route.title = routeDetailsDisplayNode.currentRouteTitle
            routeDetailsDisplayNode.state = .loaded(route)
            routeDetailsDisplayNode.isEditing = false
            navigationItem.setRightBarButtonItems(
                authManager.isLoggedIn ? [moreBarButton] : [editBarButton],
                animated: true
            )
            return
        }

        var newRoute = route

        newRoute.title = routeDetailsDisplayNode.currentRouteTitle
        databaseManager.updateRoute(newRoute)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.route = newRoute
                strongSelf.routeDetailsDisplayNode.state
                    = .loaded(strongSelf.route)
                strongSelf.routeDetailsDisplayNode.isEditing = false
                strongSelf.navigationItem
                    .setRightBarButtonItems(
                        strongSelf.authManager.isLoggedIn
                            ? [strongSelf.moreBarButton]
                            : [strongSelf.editBarButton],
                        animated: true
                )
                InformerNode.showInformer(
                    for: strongSelf.node,
                    with: NSLocalizedString("route_saved", comment: ""),
                    informerColor: "21C064"
                )
            }, onError: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                InformerNode.showInformer(
                    for: strongSelf.node, 
                    with: NSLocalizedString("informer.network_error", comment: "")
                )
            })
            .addDisposableTo(disposeBag)
    }

    func hideKeyboard() {
        view.endEditing(false)
    }
}
