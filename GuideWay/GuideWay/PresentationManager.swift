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

    func getRouteMapViewController() -> RouteMapViewController {
        return *!scope
    }

    // Nodes

    func getRouteDetailsDisplayNode(with state: RouteDetailsDisplayNode.State) -> RouteDetailsDisplayNode {
        return try! scope.resolve(arg: state)
    }

    func getRouteDetailsTitleCellNode(with title: String? = nil,
                                      editingMode: Bool) -> RouteDetailsTitleCellNode {
        if let title = title {
            return try! scope.resolve(
                arg: title,
                editingMode
            )
        } else {
            return try! scope.resolve(arg: editingMode)
        }
    }

    func getRouteDetailsMapCellNode(for route: Route) -> RouteDetailsMapCellNode {
        return try! scope.resolve(arg: route)
    }

    func getRouteDetailsOriginDestinationCellNode(for route: Route) -> RouteDetailsOriginDestinationRouteCellNode {
        return try! scope.resolve(arg: route)
    }

    func getRouteMapDisplayNode() -> RouteMapDisplayNode {
        return *!scope
    }
}
