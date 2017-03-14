//
//  RouteMapDisplayNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/14/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit
import GoogleMaps

class RouteMapDisplayNode: ASDisplayNode {
    let route: Route

    init(route: Route) {
        self.route = route
        super.init()
        backgroundColor = .green
    }
}
