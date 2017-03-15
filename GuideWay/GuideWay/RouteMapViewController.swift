//
//  MapViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/14/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteMapViewController: ASViewController<ASDisplayNode> {
    enum Mode {
        case practice
        case testing
    }

    let presentationManager: PresentationManager
    let routeMapDisplayNode: RouteMapDisplayNode
    let route: Route
    let mode: Mode

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    init(presentationManager: PresentationManager,
         route: Route,
         mode: Mode) {
        self.presentationManager = presentationManager
        self.route = route
        self.mode = mode
        routeMapDisplayNode = self.presentationManager
            .getRouteMapDisplayNode(with: self.route, mode: self.mode)

        let firstNode = ASDisplayNode()

        firstNode.backgroundColor = UIColor(hexString: "4A90E2")

        let mainNode = ASDisplayNode()

        mainNode.automaticallyManagesSubnodes = true
        super.init(node: mainNode)
        mainNode.layoutSpecBlock = { node, constrainedSize in
            firstNode.style.flexBasis = ASDimensionMake(20)
            self.routeMapDisplayNode.style.flexGrow = 1
            self.routeMapDisplayNode.style.flexShrink = 1
            return ASStackLayoutSpec(
                direction: .vertical,
                spacing: 0,
                justifyContent: .start,
                alignItems: .stretch,
                children: [firstNode, self.routeMapDisplayNode]
            )
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        routeMapDisplayNode.onExitButtonTap = { [unowned self] in
            if self.mode == .testing {
                let alertController = UIAlertController(
                    title: NSLocalizedString("alert.title.warning", comment: ""), 
                    message: NSLocalizedString("alert.warning.testing_exit", comment: ""), 
                    preferredStyle: .alert
                )
                let okButtonAction = UIAlertAction(
                    title: NSLocalizedString("alert.warning.yes", comment: ""), 
                    style: .destructive, 
                    handler: { [unowned self] _ in
                        self.dismiss(animated: true, completion: nil)
                })
                let cancelButtonAction = UIAlertAction(
                    title: NSLocalizedString("alert.warning.no", comment: ""), 
                    style: .cancel, 
                    handler: nil
                )

                alertController.addAction(cancelButtonAction)
                alertController.addAction(okButtonAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
