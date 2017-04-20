//
//  RoutesListViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 4/19/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RoutesListViewController: ASViewController<ASDisplayNode> {
    let routesListDisplayNode: RoutesListDisplayNode
    let authManager: AuthManager
    let databaseManager: DatabaseManager

    init(routesListDisplayNode: RoutesListDisplayNode, 
         authManager: AuthManager, 
         databaseManager: DatabaseManager) {
        self.routesListDisplayNode = RoutesListDisplayNode()
        self.authManager = authManager
        self.databaseManager = databaseManager
        super.init(node: routesListDisplayNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
