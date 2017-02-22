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
        builder.register { ViewController() }
            .lifetime(.perDependency)
    }
}
