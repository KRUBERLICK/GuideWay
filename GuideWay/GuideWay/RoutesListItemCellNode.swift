//
//  RoutesListItemCellNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 4/20/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RoutesListItemCellNode: ASCellNode {
    let route: Route

    init(route: Route) {
        self.route = route
        super.init()
        automaticallyManagesSubnodes = true
    }
}
