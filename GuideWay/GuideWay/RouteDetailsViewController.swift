//
//  RouteDetailsViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/24/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteDetailsViewController: ASViewController<ASDisplayNode> {
    let routeDetailsDisplayNode: RouteDetailsDisplayNode
    var route: Route

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var shouldAutorotate: Bool {
        return false
    }

    init(routeDetailsDisplayNode: RouteDetailsDisplayNode,
         route: Route) {
        self.routeDetailsDisplayNode = routeDetailsDisplayNode
        self.route = route
        super.init(node: routeDetailsDisplayNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(
            false,
            animated: true
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
