//
//  AppDelegate.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/22/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit
import DITranquillity
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        window = UIWindow()

        let builder = DIContainerBuilder()

        builder.register(assembly: AppAssembly())

        let scope = try! builder.build()
        let presentationManager: PresentationManager = *!scope

        window?.rootViewController = presentationManager.getInitialViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
