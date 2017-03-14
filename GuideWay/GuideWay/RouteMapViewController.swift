//
//  MapViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/14/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteMapViewController: ASViewController<ASDisplayNode> {
    let presentationManager: PresentationManager
    let routeMapDisplayNode: RouteMapDisplayNode

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(presentationManager: PresentationManager) {
        self.presentationManager = presentationManager
        routeMapDisplayNode = self.presentationManager.getRouteMapDisplayNode()

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
}
