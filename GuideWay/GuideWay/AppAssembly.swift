//
//  AppAssembly.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/22/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import DITranquillity

class AppAssembly: DIAssembly {
    var publicModules: [DIModule] = [DataLayerModule(),
                                     PresentationLayerModule()]
    var internalModules: [DIModule] = []
    var dependencies: [DIAssembly] = []
}
