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

    override var shouldAutorotate: Bool {
        return false
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
        routeDetailsDisplayNode.onPracticeTap = {
            self.present(self.presentationManager.getMapViewController(),
                         animated: true,
                         completion: nil)
        }
        routeDetailsDisplayNode.onTestTap = {
            self.present(self.presentationManager.getMapViewController(),
                         animated: true,
                         completion: nil)
        }
        navigationController?.navigationBar
            .barTintColor = UIColor(hexString: "626466")
        navigationController?.navigationBar
            .titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
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
        navigationItem.setRightBarButtonItems(
            [editConfirmBarButton, editCancelBarButton], 
            animated: true
        )
        routeDetailsDisplayNode.isEditing = true
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
