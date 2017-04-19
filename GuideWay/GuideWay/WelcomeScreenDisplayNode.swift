//
//  WelcomeScreenDisplayNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 4/19/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class WelcomeScreenDisplayNode: ASDisplayNode {
    let titleTextNode: ASTextNode = {
        let node = ASTextNode()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor.white, 
            NSFontAttributeName: UIFont.systemFont(
                ofSize: 70, 
                weight: UIFontWeightUltraLight
            )
        ]

        node.attributedText = NSAttributedString(
            string: NSLocalizedString("guideway", comment: ""), 
            attributes: textAttribs
        )
        return node
    }()

    lazy var loginButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor.white, 
            NSFontAttributeName: UIFont.systemFont(ofSize: 25)
        ]

        node.setAttributedTitle(
            NSAttributedString(
                string: NSLocalizedString("welcome_screen.login", comment: ""), 
                attributes: textAttribs
            ), for: []
        )
        node.addTarget(
            self, 
            action: #selector(WelcomeScreenDisplayNode.loginButtonTapped), 
            forControlEvents: .touchUpInside
        )
        return node
    }()

    lazy var demoButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.systemFont(ofSize: 25)
        ]

        node.setAttributedTitle(
            NSAttributedString(
                string: NSLocalizedString("welcome_screen.demo", comment: ""),
                attributes: textAttribs
            ), for: []
        )
        node.addTarget(
            self,
            action: #selector(WelcomeScreenDisplayNode.demoButtonTapped),
            forControlEvents: .touchUpInside
        )
        return node
    }()

    var onLoginTap: (() -> ())?
    var onDemoTap: (() -> ())?

    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(
                top: 128, 
                left: CGFloat.infinity, 
                bottom: CGFloat.infinity, 
                right: CGFloat.infinity
            ),
            child: titleTextNode
        )
        let loginDemoStack = ASStackLayoutSpec(
            direction: .horizontal, 
            spacing: 0, 
            justifyContent: .spaceBetween, 
            alignItems: .center, 
            children: [loginButtonNode, demoButtonNode]
        )
        let loginDemoStackInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(
                top: CGFloat.infinity, 
                left: 16, 
                bottom: 20, 
                right: 16
            ),
            child: loginDemoStack
        )
        let loginDemoOverlay = ASOverlayLayoutSpec(
            child: titleInsets, 
            overlay: loginDemoStackInsets
        )

        return loginDemoOverlay
    }

    override func layout() {
        super.layout()
        setupGradientBackground()
    }

    func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(hexString: "309230").cgColor,
                                UIColor(hexString: "8EB537").cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func loginButtonTapped() {
        onLoginTap?()
    }

    func demoButtonTapped() {
        onDemoTap?()
    }
}
