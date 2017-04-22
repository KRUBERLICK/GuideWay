//
//  RoutesListViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 4/19/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

class RoutesListViewController: ASViewController<ASDisplayNode> {
    let presentationManager: PresentationManager
    let routesListDisplayNode: RoutesListDisplayNode
    let authManager: AuthManager
    let databaseManager: DatabaseManager
    var userRoutes: [Route] = []
    let disposeBag = DisposeBag()

    lazy var logoutBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            title: NSLocalizedString("logout", comment: ""), 
            style: .plain, 
            target: self, 
            action: #selector(RoutesListViewController.logoutButtonTapped)
        )
    }()

    lazy var addRouteBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            barButtonSystemItem: .add, 
            target: self, 
            action: #selector(RoutesListViewController.addRouteButtonTapped)
        )
    }()

    let activityIndicatorBarButton: UIBarButtonItem = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .white)

        view.startAnimating()

        let barButton = UIBarButtonItem(customView: view)

        return barButton
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    init(presentationManager: PresentationManager,
         authManager: AuthManager, 
         databaseManager: DatabaseManager) {
        self.presentationManager = presentationManager
        routesListDisplayNode = presentationManager.getRoutesListDisplayNode()
        self.authManager = authManager
        self.databaseManager = databaseManager
        super.init(node: routesListDisplayNode)
        routesListDisplayNode.collectionNode.dataSource = self
        routesListDisplayNode.collectionNode.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString(
            "routes_list.title",
            comment: ""
        )
        navigationItem.leftBarButtonItem = logoutBarButton
        navigationItem.rightBarButtonItem = addRouteBarButton
databaseManager.getRoutesList(forUserId: authManager.currentUserId)
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: { [weak self] route in
        guard let strongSelf = self else {
            return
        }

        strongSelf.userRoutes.append(route)
        strongSelf.routesListDisplayNode.collectionNode
            .performBatch(
                animated: true, 
                updates: {
                    strongSelf.routesListDisplayNode.collectionNode
                        .insertItems(at: [IndexPath(item: strongSelf.userRoutes.count - 1,
                                                    section: 0)])
        }, completion: nil)
    })
    .addDisposableTo(disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar
            .barTintColor = UIColor(hexString: "5A9EC6")
        navigationController?.navigationBar
            .titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        navigationController?.setNavigationBarHidden(
            false,
            animated: true
        )
    }

    func logoutButtonTapped() {
        navigationItem.leftBarButtonItem = activityIndicatorBarButton
        self.authManager.logout()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.navigationItem.leftBarButtonItem = strongSelf.logoutBarButton
                strongSelf.transitToWelcomeScreen()
            }, onError: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.navigationItem.leftBarButtonItem = strongSelf.logoutBarButton
                InformerNode.showInformer(
                    for: strongSelf.node, 
                    with: NSLocalizedString("error.unknown_error", comment: "")
                )
            })
            .addDisposableTo(disposeBag)
    }

    func addRouteButtonTapped() {
        let routeSetupVC = presentationManager.getRouteSetupViewController()

        navigationController?.pushViewController(routeSetupVC, animated: true)
    }

    func transitToWelcomeScreen() {
        guard let window = view.window else {
            return
        }

        let welcomeScreenViewController = BaseNavigationController(
            rootViewController: presentationManager.getWelcomeScreenViewController()
        )

        UIView.performWithoutAnimation {
            welcomeScreenViewController.view.setNeedsLayout()
            welcomeScreenViewController.view.layoutIfNeeded()
        }
        UIView.transition(with: window,
                          duration: 0.5,
                          options: .transitionFlipFromRight,
                          animations: {
                            window.rootViewController = welcomeScreenViewController
        }, completion: nil)
    }
}

extension RoutesListViewController: ASCollectionDataSource, ASCollectionDelegate, ASCollectionDelegateFlowLayout {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode, 
                        numberOfItemsInSection section: Int) -> Int {
        return userRoutes.count
    }

    func collectionNode(_ collectionNode: ASCollectionNode, 
                        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let route = userRoutes[indexPath.item]
        let indexPath = indexPath

        return { [unowned self] in
            let cellNode = RoutesListItemCellNode(
                route: route, 
                databaseManager: self.databaseManager
            )

            cellNode.onTap = { [unowned self] route in
                let routeDetailsVC = self.presentationManager
                    .getRouteDetailsViewController(for: route)

                routeDetailsVC.onRouteDelete = { [unowned self] in
                    self.userRoutes.remove(at: indexPath.item)
                    self.routesListDisplayNode.collectionNode.performBatch(
                        animated: true, 
                        updates: {
                            self.routesListDisplayNode.collectionNode
                                .deleteItems(at: [indexPath])
                    }, completion: nil)
                }
                self.navigationController?.pushViewController(
                    routeDetailsVC, 
                    animated: true
                )
            }
            return cellNode
        }
    }

    func collectionNode(_ collectionNode: ASCollectionNode, 
                        constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let width = collectionNode.bounds.width - 44

        return ASSizeRangeMake(
            CGSize(width: width, height: 0), 
            CGSize(width: width, height: CGFloat.infinity)
        )
    }

    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout, 
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
}
