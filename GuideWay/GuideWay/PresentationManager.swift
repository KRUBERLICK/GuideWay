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
        return BaseNavigationController(rootViewController: getWelcomeScreenViewController())
    }

    func getWelcomeScreenViewController() -> WelcomeScreenViewController {
        return *!scope
    }

    func getLoginViewController() -> LoginViewController {
        return *!scope
    }

    func getRouteSetupViewController() -> RouteSetupViewController {
        return *!scope
    }

    func getRouteDetailsViewController(for route: Route) -> RouteDetailsViewController {
        return try! scope.resolve(arg: route)
    }

    func getRouteMapViewController(with route: Route,
                                   mode: RouteMapViewController.Mode) -> RouteMapViewController {
        return try! scope.resolve(arg: route, mode)
    }

    func getRouteManeuversListViewController(with route: Route,
                                             passIndex: Int? = nil) -> RouteManeuversListViewController {
        return try! scope.resolve(arg: route, passIndex)
    }

    // Nodes

    func getWelcomeScreenDisplayNode() -> WelcomeScreenDisplayNode {
        return *!scope
    }

    func getLoginDisplayNode() -> LoginDisplayNode {
        return *!scope
    }

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

    func getRouteDetailsStatisticsTitleCellNode() -> RouteDetailsStatisticsTitleCellNode {
        return *!scope
    }

    func getRouteDetailsStatisticsItemCellNode(for route: Route, passIndex: Int) -> RouteDetailsStatisticsItemCellNode {
        return try! scope.resolve(arg: route, passIndex)
    }

    func getRouteMapDisplayNode(with route: Route, 
                                mode: RouteMapViewController.Mode) -> RouteMapDisplayNode {
        return try! scope.resolve(arg: route, mode)
    }

    func getRouteManeuversListDisplayNode(with route: Route,
                                          passIndex: Int? = nil) -> RouteManeuversListDisplayNode {
        return try! scope.resolve(arg: route, passIndex)
    }

    func getRouteManeuverCellNode(maneuverText: String,
                                  maneuverType: RouteManeuver?,
                                  isFailed: Bool) -> RouteManeuverCellNode {
        return try! scope.resolve(arg: maneuverText, maneuverType, isFailed)
    }
}
