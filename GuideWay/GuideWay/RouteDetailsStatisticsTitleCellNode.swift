//
//  RouteDetailsStatisticsTitleCellNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/21/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteDetailsStatisticsTitleCellNode: ASCellNode {
    let titleTextNode = ASTextNode()

    override init() {
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor.white, 
            NSFontAttributeName: UIFont.systemFont(ofSize: 30)
        ]

        titleTextNode.attributedText = NSAttributedString(
            string: NSLocalizedString("route_details.statistics_title", comment: ""),
            attributes: textAttribs
        )
        super.init()
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets(
                top: 40,
                left: CGFloat.infinity, 
                bottom: 19, 
                right: CGFloat.infinity
            ),
            child: titleTextNode
        )
    }
}
