//
//  PresentationLayerModule.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/22/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import DITranquillity

class PresentationLayerModule: DIModule {
    func load(builder: DIContainerBuilder) {
        builder.register { PresentationManager(scope: $0) }
            .lifetime(.perDependency)
        // ViewControllers
        builder.register {
            RouteSetupViewController(
                routeSetupDisplayNode: *!$0,
                keyboardController: *!$0,
                autocompleteController: *!$0,
                googleServicesAPI: *!$0,
                presentationManager: *!$0
            )
            }
            .dependency {
                $1.autocompleteController.parentNode = $1.node
            }
            .lifetime(.perDependency)
        builder.register {
            RouteDetailsViewController(
                presentationManager: *!$0,
                route: $1,
                googleServicesAPI: *!$0
            )
            }
            .lifetime(.perDependency)
        builder.register {
            RouteMapViewController(presentationManager: *!$0,
                                   route: $1,
                                   mode: $2)
            }
            .lifetime(.perDependency)
        builder.register(RouteManeuversListViewController.self)
            .initializer { 
                RouteManeuversListViewController(
                    presentationManager: *!$0, 
                    route: $1
                )
            }
            .initializer {
                RouteManeuversListViewController(
                    presentationManager: *!$0, 
                    route: $1, 
                    passIndex: $2
                )
            }
            .lifetime(.perDependency)
        builder.register { WelcomeScreenViewController(presentationManager: *!$0) }
            .lifetime(.perDependency)
        builder.register { LoginViewController(presentationManager: *!$0,
                                               keyboardController: *!$0) }
            .lifetime(.perDependency)
        // Nodes
        builder.register { WelcomeScreenDisplayNode() }
            .lifetime(.perDependency)
        builder.register { LoginDisplayNode() }
            .lifetime(.perDependency)
        builder.register { RouteSetupDisplayNode() }
            .lifetime(.perDependency)
        builder.register {
            RouteDetailsDisplayNode(
                presentationManager: *!$0,
                state: $1
            )
            }
            .lifetime(.perDependency)
        builder.register(RouteDetailsTitleCellNode.self)
            .initializer {
                RouteDetailsTitleCellNode(isEditing: $1)
            }
            .initializer {
                RouteDetailsTitleCellNode(
                    title: $1,
                    isEditing: $2
                )
            }
            .lifetime(.perDependency)
        builder.register { RouteDetailsMapCellNode(route: $1) }
            .lifetime(.perDependency)
        builder.register {
            RouteDetailsOriginDestinationRouteCellNode(
                route: $1
            )
            }
            .lifetime(.perDependency)
        builder.register { RouteMapDisplayNode(route: $1, mode: $2) }
            .lifetime(.perDependency)
        builder.register { RouteDetailsStatisticsTitleCellNode() }
            .lifetime(.perDependency)
        builder.register {
            RouteDetailsStatisticsItemCellNode(
                route: $1,
                passIndex: $2
            )
            }
            .lifetime(.perDependency)
        builder.register(RouteManeuversListDisplayNode.self)
            .initializer {
                RouteManeuversListDisplayNode(
                    presentationManager: *!$0,
                    route: $1
                )
            }
            .initializer {
                RouteManeuversListDisplayNode(
                    presentationManager: *!$0,
                    route: $1, 
                    passIndex: $2
                )
            }
            .lifetime(.perDependency)
        builder.register { 
            RouteManeuverCellNode(
                maneuverText: $1, 
                maneuverType: $2,
                isFailed: $3
            )
            }
            .lifetime(.perDependency)
        // Utils
        builder.register { KeyboardController() }
            .lifetime(.perDependency)
        builder.register { AutocompleteController() }
            .lifetime(.perDependency)
    }
}
