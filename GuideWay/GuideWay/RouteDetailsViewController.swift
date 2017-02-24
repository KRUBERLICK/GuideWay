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

    init(routeDetailsDisplayNode: RouteDetailsDisplayNode,
         route: Route) {
        self.routeDetailsDisplayNode = routeDetailsDisplayNode
        self.route = route
        super.init(node: routeDetailsDisplayNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(
            false,
            animated: true
        )
    }
}
