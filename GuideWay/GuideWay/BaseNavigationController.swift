//
//  BaseNavigationController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/24/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class BaseNavigationController: ASNavigationController {
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return topViewController
    }

    override var childViewControllerForStatusBarHidden: UIViewController? {
        return topViewController
    }

    override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? super.shouldAutorotate
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        topViewController?.navigationItem.backBarButtonItem =
            UIBarButtonItem(title: "",
                            style: .plain,
                            target: nil,
                            action: nil)
    }
}
