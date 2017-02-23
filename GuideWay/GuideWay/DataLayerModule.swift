//
//  DataLayerModule.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/23/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import DITranquillity

class DataLayerModule: DIModule {
    func load(builder: DIContainerBuilder) {
        builder.register { WebService() }
            .lifetime(.lazySingle)
    }
}
