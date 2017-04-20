//
//  ReachabilityProvider.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 4/20/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import Firebase
import RxSwift

class ReachabilityProvider {
    private var connectedReference: FIRDatabaseReference {
        return database.reference(withPath: ".info/connected")
    }

    var firebaseReachabilityStatus = Variable<Bool>(false)
    let database: FIRDatabase

    init(database: FIRDatabase) {
        self.database = database
        connectedReference.observe(.value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }

            if let connected = snapshot.value as? Bool, connected {
                strongSelf.firebaseReachabilityStatus.value = true
            } else {
                strongSelf.firebaseReachabilityStatus.value = false
            }
        })
    }
}
