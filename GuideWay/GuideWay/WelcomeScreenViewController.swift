//
//  WelcomeScreenViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 4/19/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class WelcomeScreenViewController: ASViewController<ASDisplayNode> {
    let presentationManager: PresentationManager
    let welcomeScreenDisplayNode: WelcomeScreenDisplayNode

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    init(presentationManager: PresentationManager) {
        self.presentationManager = presentationManager
        welcomeScreenDisplayNode = presentationManager.getWelcomeScreenDisplayNode()
        super.init(node: welcomeScreenDisplayNode)
        welcomeScreenDisplayNode.onLoginTap = { [unowned self] in

        }
        welcomeScreenDisplayNode.onDemoTap = { [unowned self] in
            let routeSetupVC = self.presentationManager.getRouteSetupViewController()

            self.navigationController?.pushViewController(routeSetupVC, animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString(
            "welcome",
            comment: ""
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar
            .barTintColor = UIColor(hexString: "487848")
        navigationController?.navigationBar
            .titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        navigationController?.setNavigationBarHidden(
            false,
            animated: true
        )
    }
}
