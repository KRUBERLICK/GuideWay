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
        // Nodes
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
        // Utils
        builder.register { KeyboardController() }
            .lifetime(.perDependency)
        builder.register { AutocompleteController() }
            .lifetime(.perDependency)
    }
}
