//
//  RouteSetupDisplayNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/22/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteSetupDisplayNode: ASDisplayNode {
    let backgroundImageNode: ASImageNode = {
        let node = ASImageNode()

        node.image = #imageLiteral(resourceName: "img_route_setup_bg")
        node.contentMode = .scaleAspectFill
        return node
    }()

    let routeImageNode: ASImageNode = {
        let node = ASImageNode()

        node.image = #imageLiteral(resourceName: "ic_route")
        node.contentMode = .scaleAspectFill
        return node
    }()

    let createNewRouteTitleNode: ASTextNode = {
        let node = ASTextNode()
        let textAttribs = [NSForegroundColorAttributeName: UIColor.white,
                           NSFontAttributeName: UIFont.systemFont(ofSize: 35,
                                                                  weight: UIFontWeightLight)]

        node.attributedText = NSAttributedString(
            string: NSLocalizedString("route_setup.create_new_route", comment: ""),
            attributes: textAttribs
        )
        return node
    }()

    lazy var textFieldBuilder: (String) -> UITextField = { placeholder in
        let textField = UITextField()
        let textAttribs = [NSForegroundColorAttributeName: UIColor.white,
                           NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
        let placeholderAttribs = [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.6),
                                  NSFontAttributeName: UIFont.systemFont(ofSize: 15)]

        textField.defaultTextAttributes = textAttribs
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: placeholderAttribs
        )
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }

    lazy var originTextFieldNode: ASDisplayNode = {
        return ASDisplayNode(
            viewBlock: { [unowned self] in
                self.textFieldBuilder(
                    NSLocalizedString("route_setup.origin", comment: "")
                )
            }
        )
    }()

    lazy var destinationTextFieldNode: ASDisplayNode = {
        return ASDisplayNode(
            viewBlock: { [unowned self] in
                self.textFieldBuilder(
                    NSLocalizedString("route_setup.destination", comment: "")
                )
            }
        )
    }()

    let originIconNode: ASImageNode = {
        let node = ASImageNode()

        node.image = #imageLiteral(resourceName: "ic_mark_border")
        return node
    }()

    let destinationIconNode: ASImageNode = {
        let node = ASImageNode()

        node.image = #imageLiteral(resourceName: "ic_mark_border")
        return node
    }()

    let originTextFieldUnderscoreNode: ASDisplayNode = {
        let node = ASDisplayNode()

        node.backgroundColor = UIColor(white: 1, alpha: 0.5)
        return node
    }()

    let destinationTextFieldUnderscoreNode: ASDisplayNode = {
        let node = ASDisplayNode()

        node.backgroundColor = UIColor(white: 1, alpha: 0.5)
        return node
    }()

    lazy var createRouteButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setImage(#imageLiteral(resourceName: "ic_arrow_right"), for: [])
        node.backgroundColor = UIColor(hexString: "21C064")
        node.addTarget(
            self, 
            action: #selector(RouteSetupDisplayNode.createRouteButtonTapped),
            forControlEvents: .touchUpInside
        )
        return node
    }()

    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let routeImageAndTitleStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 17,
            justifyContent: .center,
            alignItems: .center,
            children: [routeImageNode, createNewRouteTitleNode]
        )

        originTextFieldNode.style.flexShrink = 1
        originTextFieldNode.style.flexGrow = 1
        destinationTextFieldNode.style.flexGrow = 1
        destinationTextFieldNode.style.flexShrink = 1

        let originTextFieldAndIconStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 12,
            justifyContent: .start,
            alignItems: .center,
            children: [originIconNode, originTextFieldNode]
        )
        let destinationTextFieldAndIconStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 12, 
            justifyContent: .start, 
            alignItems: .center, 
            children: [destinationIconNode, destinationTextFieldNode]
        )

        originTextFieldAndIconStack.style.flexBasis = ASDimensionMake(50)
        destinationTextFieldAndIconStack.style.flexBasis = ASDimensionMake(50)
        originTextFieldUnderscoreNode.style.flexBasis = ASDimensionMake(1)
        destinationTextFieldUnderscoreNode.style.flexBasis = ASDimensionMake(1)

        let originTextFieldUnderscore = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .stretch,
            children: [originTextFieldAndIconStack, originTextFieldUnderscoreNode]
        )
        let destinationTextFieldUnderscore = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .stretch,
            children: [destinationTextFieldAndIconStack, destinationTextFieldUnderscoreNode]
        )
        let textFieldsStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 0, 
            justifyContent: .start, 
            alignItems: .stretch, 
            children: [originTextFieldUnderscore, destinationTextFieldUnderscore]
        )
        let textFieldsInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 31, bottom: 0, right: 31), 
            child: textFieldsStack
        )
        let addTextFieldsStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 50,
            justifyContent: .start,
            alignItems: .stretch,
            children: [routeImageAndTitleStack, textFieldsInsets]
        )
        let addTextFieldsStackInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 70, left: 0, bottom: 0, right: 0),
            child: addTextFieldsStack
        )

        createRouteButtonNode.style.preferredSize.height = 55

        let createRouteButtonInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: CGFloat.infinity, left: 0, bottom: 0, right: 0), 
            child: createRouteButtonNode
        )
        let createRouteButtonOverlay = ASOverlayLayoutSpec(
            child: addTextFieldsStackInsets,
            overlay: createRouteButtonInsets
        )
        let backgroundImage = ASOverlayLayoutSpec(
            child: backgroundImageNode,
            overlay: createRouteButtonOverlay
        )
        return backgroundImage
    }

    func createRouteButtonTapped() {

    }
}

extension RouteSetupDisplayNode: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
