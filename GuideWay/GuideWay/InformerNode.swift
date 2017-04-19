//
//  InformerNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/3/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class InformerNode: ASDisplayNode {
    let messageTextNode = ASTextNode()

    lazy var closeButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setImage(#imageLiteral(resourceName: "ic_close"), for: [])
        return node
    }()

    var closeTimer: Timer?

    init(message: String) {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor(hexString: "C23E3E")

        let textAttribs = [
            NSForegroundColorAttributeName: UIColor.white, 
            NSFontAttributeName: UIFont.systemFont(ofSize: 17)
        ]

        messageTextNode.attributedText = NSAttributedString(
            string: message, 
            attributes: textAttribs
        )
    }

    override func didLoad() {
        super.didLoad()
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, 
                action: #selector(InformerNode.close)
            )
        )
        closeTimer = Timer.scheduledTimer(
            timeInterval: 2, 
            target: self, 
            selector: #selector(InformerNode.close), 
            userInfo: nil, 
            repeats: false
        )
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let messageAndCloseButtonStack = ASStackLayoutSpec(
            direction: .horizontal, 
            spacing: 0, 
            justifyContent: .spaceBetween, 
            alignItems: .center, 
            children: [messageTextNode, 
                       closeButtonNode]
        )
        let messageAndCloseButtonStackInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15),
            child: messageAndCloseButtonStack
        )

        return messageAndCloseButtonStackInsets
    }

    static func showInformer(for node: ASDisplayNode,
                      with message: String) {
        node.subnodes
            .filter { type(of: $0) == InformerNode.self }
            .forEach { ($0 as? InformerNode)?.close() }

        let informerNode = InformerNode(message: message)
        let calculatedLayout = informerNode.calculateLayoutThatFits(
            ASSizeRangeMake(
                CGSize(width: node.bounds.width, height: 0), 
                CGSize(width: node.bounds.width, height: CGFloat.infinity)
            )
        )

        informerNode.frame = CGRect(
            x: 0, 
            y: -calculatedLayout.size.height,
            width: node.bounds.width, 
            height: calculatedLayout.size.height
        )
        node.addSubnode(informerNode)
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                informerNode.frame.origin.y = 0
        }, completion: nil)
    }

    func close() {
        closeTimer?.invalidate()
        closeTimer = nil
        UIView.animate(
            withDuration: 0.25, 
            delay: 0, 
            options: .curveEaseOut, 
            animations: {
                self.frame.origin.y = -self.bounds.height
        }, completion: { _ in
            self.removeFromSupernode()
        })
    }
}
