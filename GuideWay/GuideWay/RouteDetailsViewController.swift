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

    init(presentationManager: PresentationManager,
         route: Route,
         googleServicesAPI: GoogleServicesAPI) {
        self.presentationManager = presentationManager
        self.routeDetailsDisplayNode =
            presentationManager.getRouteDetailsDisplayNode(with: .loading)
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
                self.route = route
                self.routeDetailsDisplayNode.state = .loaded(self.route)
                self.routeDetailsDisplayNode.collectionNode.reloadData()
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
        requestRouteDirections()
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
            .subscribe(onNext: { [unowned self] response in
                self.route.directions = response.routes.first

                guard let _ = self.route.directions else {
                    self.navigationItem.setRightBarButtonItems([], animated: true)
                    self.routeDetailsDisplayNode.state = .noDirections
                    return
                }

                self.navigationItem.setRightBarButtonItems(
                    [self.editBarButton], 
                    animated: true
                )
                self.routeDetailsDisplayNode.state = .loaded(self.route)
            }, onError: { error in
                self.navigationItem.setRightBarButtonItems([], animated: true)
                self.routeDetailsDisplayNode.state = .loadingFailed
            })
            .addDisposableTo(disposeBag)
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

    func editCancelButtonTapped() {
        routeDetailsDisplayNode.isEditing = false
        navigationItem.setRightBarButtonItems(
            [editBarButton], 
            animated: true
        )
    }

    func editConfirmButtonTapped() {
        InformerNode.showInformer(for: node, with: "Error")
        // Send route update request, if not in demo mode
        route.title = routeDetailsDisplayNode.currentRouteTitle
        routeDetailsDisplayNode.state = .loaded(route)
        routeDetailsDisplayNode.isEditing = false
        navigationItem.setRightBarButtonItems(
            [editBarButton], 
            animated: true
        )
    }

    func hideKeyboard() {
        view.endEditing(false)
    }
}
