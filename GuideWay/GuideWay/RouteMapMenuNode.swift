//
//  RouteMapMenuNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/14/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteMapMenuNode: ASDisplayNode {
    lazy var openMenuButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setImage(#imageLiteral(resourceName: "ic_menu_circle"), for: [])
        node.addTarget(
            self,
            action: #selector(RouteMapMenuNode.openMenuButtonTapped),
            forControlEvents: .touchUpInside
        )
        return node
    }()

    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .clear
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let buttonsStack =  ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 0, 
            justifyContent: .start, 
            alignItems: .end, 
            children: [openMenuButtonNode]
        )
        let insets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), 
            child: buttonsStack
        )

        return insets
    }

    func openMenuButtonTapped() {
        // open menu
    }

    override func point(inside point: CGPoint,
                        with event: UIEvent?) -> Bool {
        return openMenuButtonNode.frame.contains(point)
    }
}
