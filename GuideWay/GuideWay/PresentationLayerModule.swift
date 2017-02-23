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
            RouteSetupViewController(routeSetupDisplayNode: *!$0,
                                     keyboardController: *!$0,
                                     autocompleteController: *!$0)
            }
            .dependency { $1.autocompleteController.parentNode = $1.node }
            .lifetime(.perDependency)
        // Nodes
        builder.register { RouteSetupDisplayNode() }
            .lifetime(.perDependency)
        // Utils
        builder.register { KeyboardController() }
            .lifetime(.perDependency)
        builder.register { AutocompleteController() }
            .lifetime(.perDependency)
    }
}
