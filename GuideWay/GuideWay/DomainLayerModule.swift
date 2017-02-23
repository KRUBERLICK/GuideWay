//
//  DomainLayerModule.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/23/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import DITranquillity

class DomainLayerModule: DIModule {
    func load(builder: DIContainerBuilder) {
        builder.register { GoogleServicesAPI(webService: *!$0) }
            .lifetime(.lazySingle)
    }
}