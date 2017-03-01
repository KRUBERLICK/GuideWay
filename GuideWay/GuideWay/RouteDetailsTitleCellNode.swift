//
//  RouteDetailsTitleCellNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/27/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteDetailsTitleCellNode: ASCellNode {
    lazy var titleTextField: UITextField = {
        let textField = UITextField()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.systemFont(
                ofSize: 40, 
                weight: UIFontWeightLight
            )
        ]

        textField.defaultTextAttributes = textAttribs
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.delegate = self
        textField.textAlignment = .center
        textField.enablesReturnKeyAutomatically = true
        return textField
    }()

    lazy var titleTextFieldNode: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [unowned self] in self.titleTextField })
    }()

    init(title: String = NSLocalizedString("route_details.route_title", comment: ""),
         isEditing: Bool) {
        super.init()
        titleTextField.isEnabled = isEditing
        automaticallyManagesSubnodes = true
        titleTextField.text = title
    }

    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        if titleTextField.isEnabled {
            titleTextField.becomeFirstResponder()
        }
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        titleTextFieldNode.style.flexBasis = ASDimensionMake(48)

        let titleTextFieldNodeStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 0, 
            justifyContent: .center, 
            alignItems: .stretch, 
            children: [titleTextFieldNode]
        )
        let titleTextFieldNodeStackInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 38, left: 20, bottom: 20, right: 19), 
            child: titleTextFieldNodeStack
        )

        return titleTextFieldNodeStackInsets
    }
}

extension RouteDetailsTitleCellNode: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
