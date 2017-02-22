//
//  ViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/22/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteSetupViewController: ASViewController<ASDisplayNode> {
    let routeSetupDisplayNode: RouteSetupDisplayNode

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(routeSetupDisplayNode: RouteSetupDisplayNode) {
        self.routeSetupDisplayNode = routeSetupDisplayNode
        super.init(node: routeSetupDisplayNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

