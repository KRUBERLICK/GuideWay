//
//  ViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/22/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteSetupViewController: ASViewController<ASDisplayNode> {
    let routeSetupDisplayNode: RouteSetupDisplayNode
    let keyboardController: KeyboardController

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    init(routeSetupDisplayNode: RouteSetupDisplayNode,
         keyboardController: KeyboardController) {
        self.routeSetupDisplayNode = routeSetupDisplayNode
        self.keyboardController = keyboardController
        super.init(node: routeSetupDisplayNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardController.parentView = view
        routeSetupDisplayNode.view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, 
                action: #selector(RouteSetupViewController.hideKeyboard)
            )
        )
        routeSetupDisplayNode.onCreateRouteButtonTap = { [unowned self] in
            self.keyboardController.hideKeyboard(completion: { 

            })
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    func hideKeyboard() {
        keyboardController.hideKeyboard()
    }
}

