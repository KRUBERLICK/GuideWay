//
//  RouteMapInfoNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 4/17/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteMapInfoNode: ASDisplayNode {
    let route: Route
    let routeTitleNode = ASTextNode()
    var originDestinationNode: RouteDetailsOriginDestinationRouteCellNode!

    let durationImageNode: ASImageNode = {
        let node = ASImageNode()

        node.image = #imageLiteral(resourceName: "ic_map_route_info_timer")
        return node
    }()

    let lengthImageNode: ASImageNode = {
        let node = ASImageNode()

        node.image = #imageLiteral(resourceName: "ic_map_route_info_ruler")
        return node
    }()

    var durationTextNode: ASTextNode!
    var lengthTextNode: ASTextNode!

    let separatorNode: ASDisplayNode = {
        let node = ASDisplayNode()

        node.backgroundColor = UIColor(hexString: "E0E0E0")
        return node
    }()

    lazy var textInstructionsButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setAttributedTitle(
            NSAttributedString(
                string: NSLocalizedString("text_instructions", comment: ""),
                attributes: [
                    NSFontAttributeName: UIFont.systemFont(ofSize: 20),
                    NSForegroundColorAttributeName: UIColor(hexString: "4990E2")
                ]
            ), for: []
        )
        node.addTarget(
            self, 
            action: #selector(RouteMapInfoNode.textInstructionsButtonNodeTapped), 
            forControlEvents: .touchUpInside
        )
        return node
    }()

    lazy var closeButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setImage(#imageLiteral(resourceName: "ic_map_close_route_info"), for: [])
        node.addTarget(
            self, 
            action: #selector(RouteMapInfoNode.closeButtonTapped), 
            forControlEvents: .touchUpInside
        )
        return node
    }()

    var onTextInstructionsButtonTap: (() -> ())?
    var onCloseButtonTap: (() -> ())?

    init(route: Route) {
        self.route = route
        super.init()
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = .white
        cornerRadius = 5
        genericInit()
    }

    func genericInit() {
        let titleTextAttribs = [NSForegroundColorAttributeName: UIColor(hexString: "616161"),
                                NSFontAttributeName: UIFont.systemFont(ofSize: 30)]

        routeTitleNode.attributedText = NSAttributedString(
            string: route.title ?? NSLocalizedString("route_details.route_title", comment: ""),
            attributes: titleTextAttribs
        )
        originDestinationNode = RouteDetailsOriginDestinationRouteCellNode(route: route, style: .dark)

        let durationLengthTextAttribs = [
            NSForegroundColorAttributeName: UIColor(hexString: "919191"), 
            NSFontAttributeName: UIFont.systemFont(ofSize: 14)
        ]
        guard let durationText = route.directions?.legs.first?.durationString,
            let distanceText = route.directions?.legs.first?.distanceString else {
                return
        }

        durationTextNode = ASTextNode()
        lengthTextNode = ASTextNode()
        durationTextNode.attributedText = NSAttributedString(
            string: durationText, 
            attributes: durationLengthTextAttribs
        )
        lengthTextNode.attributedText = NSAttributedString(
            string: distanceText, 
            attributes: durationLengthTextAttribs
        )
    }

    override func layout() {
        super.layout()
        layer.shadowColor = UIColor(white: 0, alpha: 0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 4
        layer.shadowOpacity = 1
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 37), 
            child: routeTitleNode
        )
        let durationStack = ASStackLayoutSpec(
            direction: .horizontal, 
            spacing: 6, 
            justifyContent: .center, 
            alignItems: .center, 
            children: [durationImageNode, durationTextNode]
        )
        let lengthStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 6,
            justifyContent: .center,
            alignItems: .center,
            children: [lengthImageNode, lengthTextNode]
        )
        let durationAndLengthStack = ASStackLayoutSpec(
            direction: .horizontal, 
            spacing: 0, 
            justifyContent: .spaceBetween, 
            alignItems: .center, 
            children: [durationStack, lengthStack]
        )
        let durationAndLengthStackInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 39, bottom: 14, right: 39),
            child: durationAndLengthStack
        )
        let infoStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 23,
            justifyContent: .center, 
            alignItems: .stretch,
            children: [titleInsets, 
                       originDestinationNode, 
                       durationAndLengthStackInsets]
        )

        separatorNode.style.preferredSize.height = 1 / UIScreen.main.scale

        let separatorInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 13), 
            child: separatorNode
        )

        textInstructionsButtonNode.style.flexBasis = ASDimensionMake(53)

        let finalStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 0, 
            justifyContent: .start, 
            alignItems: .stretch, 
            children: [infoStack, separatorInsets, textInstructionsButtonNode]
        )
        let finalInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 17, left: 0, bottom: 0, right: 0),
            child: finalStack
        )
        let closeButtonInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 17, left: CGFloat.infinity, bottom: CGFloat.infinity, right: 17),
            child: closeButtonNode
        )
        let closeButtonOverlay = ASOverlayLayoutSpec(
            child: finalInsets, 
            overlay: closeButtonInsets
        )

        return closeButtonOverlay
    }

    func textInstructionsButtonNodeTapped() {
        onTextInstructionsButtonTap?()
    }

    func closeButtonTapped() {
        onCloseButtonTap?()
    }
}
