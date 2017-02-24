//
//  PresentationManager.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/22/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import UIKit
import DITranquillity

class PresentationManager {
    let scope: DIScope

    init(scope: DIScope) {
        self.scope = scope
    }

    // ViewControllers

    func getInitialViewController() -> UIViewController {
        let routeSetupVC: RouteSetupViewController = *!scope

        return BaseNavigationController(rootViewController: routeSetupVC)
    }

    func getRouteDetailsViewController(for route: Route) -> RouteDetailsViewController {
        return try! scope.resolve(arg: route)
    }

    // Nodes
}
