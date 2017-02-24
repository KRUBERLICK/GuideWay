//
//  AlertNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/24/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class AlertNode: ASDisplayNode {
    let titleNode: ASTextNode = {
        let node = ASTextNode()
        let textAttribs = [NSForegroundColorAttributeName: UIColor.white,
                           NSFontAttributeName: UIFont.systemFont(ofSize: 27)]

        node.attributedText = NSAttributedString(
            string: NSLocalizedString("alert.title.error", comment: ""), 
            attributes: textAttribs
        )
        return node
    }()
    
    let messageNode = ASTextNode()

    let separatorLineNode: ASDisplayNode = {
        let node = ASDisplayNode()

        node.backgroundColor = UIColor(
            hexString: "910000",
            alpha: 0.4
        )
        return node
    }()

    lazy var okButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        let titleAttribs = [NSForegroundColorAttributeName: UIColor.white,
                            NSFontAttributeName: UIFont.systemFont(
                                ofSize: 17,
                                weight: UIFontWeightBold)]

        node.setAttributedTitle(
            NSAttributedString(
                string: NSLocalizedString("alert.ok", comment: ""),
                attributes: titleAttribs
            ),
            for: []
        )
        node.addTarget(
            self, 
            action: #selector(AlertNode.okButtonTapped), 
            forControlEvents: .touchUpInside
        )
        return node
    }()

    let backgroundNode: ASDisplayNode = {
        let node = ASDisplayNode()

        node.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return node
    }()

    var onOKTap: (() -> ())?

    init(message: String) {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor(hexString: "E0483E")

        let messageTextAttribs = [NSForegroundColorAttributeName: UIColor.white,
                                  NSFontAttributeName: UIFont.systemFont(ofSize: 17)]

        messageNode.attributedText = NSAttributedString(
            string: message, 
            attributes: messageTextAttribs
        )
        cornerRadius = 2
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textsStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 9, 
            justifyContent: .center, 
            alignItems: .stretch, 
            children: [titleNode, 
                       messageNode]
        )
        let textsStackInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16), 
            child: textsStack
        )

        separatorLineNode.style.flexBasis = ASDimensionMake(1)
        okButtonNode.style.flexBasis = ASDimensionMake(45)

        let finalStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 0, 
            justifyContent: .start,
            alignItems: .stretch, 
            children: [textsStackInsets, 
                       separatorLineNode, 
                       okButtonNode]
        )
        return finalStack
    }

    func okButtonTapped() {
        self.onOKTap?()
    }
}

class AlertWithBackgroundNode: ASDisplayNode {
    let alertNode: AlertNode

    let backgroundNode: ASDisplayNode = {
        let node = ASDisplayNode()

        node.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return node
    }()

    init(message: String) {
        alertNode = AlertNode(message: message)
        super.init()
        automaticallyManagesSubnodes = true
        alertNode.onOKTap = { [unowned self] in
            UIView.animate(withDuration: 0.25, animations: { 
                self.alpha = 0
            }, completion: { _ in
                self.removeFromSupernode()
            })
        }
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let alertNodeInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(
                top: CGFloat.infinity, 
                left: 38, 
                bottom: CGFloat.infinity, 
                right: 38
            ),
            child: alertNode
        )
        let backgroundOverlay = ASOverlayLayoutSpec(
            child: backgroundNode, 
            overlay: alertNodeInsets
        )

        return backgroundOverlay
    }

    static func showAlert(for node: ASDisplayNode,
                          with message: String) {
        let alertNode = AlertWithBackgroundNode(message: message)

        node.addSubnode(alertNode)
        alertNode.frame = node.bounds
        alertNode.alpha = 0
        UIView.animate(withDuration: 0.25) { 
            alertNode.alpha = 1
        }
    }
}
