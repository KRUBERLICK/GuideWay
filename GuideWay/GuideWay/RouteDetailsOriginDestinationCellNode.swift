//
//  RouteDetailsOriginDestinationCellNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/1/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteDetailsOriginDestinationRouteCellNode: ASCellNode {
    enum Style {
        case light
        case dark
    }

    let styleMode: Style

    let originIconNode: ASImageNode = {
        let node = ASImageNode()

        node.image = #imageLiteral(resourceName: "ic_map_origin")
        return node
    }()

    let destinationIconNode: ASImageNode = {
        let node = ASImageNode()

        node.image = #imageLiteral(resourceName: "ic_map_destination")
        return node
    }()

    lazy var originTextLabelNode: ASTextNode = {
        let node = ASTextNode()
        let textAttribs = [
            NSForegroundColorAttributeName: self.styleMode == .light
                ? UIColor.white
                : UIColor(hexString: "919191"),
            NSFontAttributeName: UIFont.systemFont(
                ofSize: 12, 
                weight: UIFontWeightLight
            )
        ]

        node.attributedText = NSAttributedString(
            string: NSLocalizedString("route_details.from_label", comment: ""), 
            attributes: textAttribs
        )
        return node
    }()

    lazy var destinationTextLabelNode: ASTextNode = {
        let node = ASTextNode()
        let textAttribs = [
            NSForegroundColorAttributeName: self.styleMode == .light
                ? UIColor.white
                : UIColor(hexString: "919191"),
            NSFontAttributeName: UIFont.systemFont(
                ofSize: 12,
                weight: UIFontWeightLight
            )
        ]

        node.attributedText = NSAttributedString(
            string: NSLocalizedString("route_details.to_label", comment: ""),
            attributes: textAttribs
        )
        return node
    }()

    let originTextNode = ASTextNode()
    let destinationTextNode = ASTextNode()
    let route: Route

    init(route: Route, style: Style = .light) {
        self.route = route
        styleMode = style
        super.init()
        automaticallyManagesSubnodes = true
        bindData()
    }

    func bindData() {
        guard let originText = route.directions?.legs
            .first?.startLocationTitle, 
            let destinationText = route.directions?.legs
                .first?.endLocationTitle else {
                    return
        }

        let textAttribs = [
            NSForegroundColorAttributeName: styleMode == .light
                ? UIColor.white
                : UIColor(hexString: "919191"),
            NSFontAttributeName: UIFont.systemFont(ofSize: 17)
        ]

        originTextNode.attributedText = NSAttributedString(
            string: originText,
            attributes: textAttribs
        )
        destinationTextNode.attributedText = NSAttributedString(
            string: destinationText,
            attributes: textAttribs
        )
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        originTextNode.style.flexShrink = 1
        destinationTextNode.style.flexShrink = 1

        let originLabelAndTextNodeStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 0, 
            justifyContent: .center,
            alignItems: .start, 
            children: [originTextLabelNode, 
                       originTextNode]
        )

        originLabelAndTextNodeStack.style.flexShrink = 1

        let originStack = ASStackLayoutSpec(
            direction: .horizontal, 
            spacing: 7, 
            justifyContent: .start, 
            alignItems: .center, 
            children: [originIconNode, 
                       originLabelAndTextNodeStack]
        )

        originStack.style.flexShrink = 1

        let destinationLabelAndTextNodeStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .center,
            alignItems: .start,
            children: [destinationTextLabelNode,
                       destinationTextNode]
        )

        destinationLabelAndTextNodeStack.style.flexShrink = 1

        let destinationStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 7,
            justifyContent: .start,
            alignItems: .center,
            children: [destinationIconNode,
                       destinationLabelAndTextNodeStack]
        )

        destinationStack.style.flexShrink = 1

        let bothStacks = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 10, 
            justifyContent: .center,
            alignItems: .start,
            children: [originStack,
                       destinationStack]
        )
        let finalStackInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 28),
            child: bothStacks
        )

        return finalStackInsets
    }
}
