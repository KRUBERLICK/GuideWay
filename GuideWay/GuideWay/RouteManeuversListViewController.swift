//
//  RouteManeuversListViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/27/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteManeuversListViewController: ASViewController<ASDisplayNode> {
    let presentationManager: PresentationManager
    let route: Route
    let routeManeuversListDisplayNode: RouteManeuversListDisplayNode

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    init(presentationManager: PresentationManager,
         route: Route,
         passIndex: Int? = nil) {
        self.presentationManager = presentationManager
        self.route = route
        routeManeuversListDisplayNode = presentationManager
            .getRouteManeuversListDisplayNode(
                with: route, 
                passIndex: passIndex
        )
        super.init(node: routeManeuversListDisplayNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar
            .barTintColor = UIColor(hexString: "4A90E2")
        navigationController?.navigationBar
            .titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = NSLocalizedString(
            "text_instructions",
            comment: ""
        )

        guard navigationController?.viewControllers.count ?? 0 == 1 else {
            return
        }

        let cancelBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self, 
            action: #selector(RouteManeuversListViewController.cancelButtonTapped)
        )

        navigationItem.rightBarButtonItem = cancelBarButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(
            false,
            animated: true
        )
    }

    func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
