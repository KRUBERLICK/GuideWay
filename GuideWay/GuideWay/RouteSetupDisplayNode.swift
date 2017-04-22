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
        textField.autocorrectionType = .no
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

        node.image = #imageLiteral(resourceName: "ic_mark_a")
        return node
    }()

    let destinationIconNode: ASImageNode = {
        let node = ASImageNode()

        node.image = #imageLiteral(resourceName: "ic_mark_b")
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

    var onCreateRouteButtonTap: (() -> ())?

    var originTextField: UITextField {
        return originTextFieldNode.view as! UITextField
    }

    var destinationTextField: UITextField {
        return destinationTextFieldNode.view as! UITextField
    }

    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundImageNode.image = #imageLiteral(resourceName: "img_route_setup_bg")
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let isNarrow = constrainedSize.max.height <= 510

        let centeredCreateNewRouteTitleNode = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 0, 
            justifyContent: .center, 
            alignItems: .center, 
            children: [createNewRouteTitleNode]
        )
        let routeImageAndTitleStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 17,
            justifyContent: .center,
            alignItems: .center,
            children: isNarrow
                ? [centeredCreateNewRouteTitleNode]
                : [routeImageNode, centeredCreateNewRouteTitleNode]
        )

        self.originTextFieldNode.style.flexShrink = 1
        self.originTextFieldNode.style.flexGrow = 1
        self.destinationTextFieldNode.style.flexGrow = 1
        self.destinationTextFieldNode.style.flexShrink = 1

        let originTextFieldAndIconStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 12,
            justifyContent: .start,
            alignItems: .center,
            children: [self.originIconNode, self.originTextFieldNode]
        )
        let destinationTextFieldAndIconStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 12,
            justifyContent: .start,
            alignItems: .center,
            children: [self.destinationIconNode, self.destinationTextFieldNode]
        )

        originTextFieldAndIconStack.style.flexBasis = ASDimensionMake(50)
        destinationTextFieldAndIconStack.style.flexBasis = ASDimensionMake(50)
        self.originTextFieldUnderscoreNode.style.flexBasis = ASDimensionMake(1)
        self.destinationTextFieldUnderscoreNode.style.flexBasis = ASDimensionMake(1)

        let originTextFieldUnderscore = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .stretch,
            children: [originTextFieldAndIconStack, self.originTextFieldUnderscoreNode]
        )
        let destinationTextFieldUnderscore = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .stretch,
            children: [destinationTextFieldAndIconStack, self.destinationTextFieldUnderscoreNode]
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
            spacing: isNarrow ? 20 : 50,
            justifyContent: .center,
            alignItems: .stretch,
            children: [routeImageAndTitleStack, textFieldsInsets]
        )

        self.createRouteButtonNode.style.preferredSize.height = 55
        addTextFieldsStack.style.flexBasis = ASDimensionMake(constrainedSize.max.height - 55)

        let addCreateRouteButton = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .stretch,
            children: [addTextFieldsStack, self.createRouteButtonNode]
        )
        let backgroundImage = ASOverlayLayoutSpec(
            child: self.backgroundImageNode,
            overlay: addCreateRouteButton
        )
        return backgroundImage
    }

    func createRouteButtonTapped() {
        onCreateRouteButtonTap?()
    }
}

extension RouteSetupDisplayNode: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
