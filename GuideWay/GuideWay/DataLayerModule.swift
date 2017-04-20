//
//  DataLayerModule.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/23/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import DITranquillity
import Firebase

class DataLayerModule: DIModule {
    func load(builder: DIContainerBuilder) {
        builder.register { WebService() }.lifetime(.lazySingle)
        builder.register { GoogleServicesAPI(webService: *!$0) }.lifetime(.lazySingle)
        builder.register { AuthManager(authProvider: FIRAuth.auth()!) }.lifetime(.lazySingle)
        builder.register { DatabaseManager(database: FIRDatabase.database()) }.lifetime(.lazySingle)
        builder.register { ReachabilityProvider(database: FIRDatabase.database()) }.lifetime(.lazySingle)
    }
}
