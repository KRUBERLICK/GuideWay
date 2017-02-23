//
//  AutocompleteController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/22/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class AutocompleteCellNode: ASCellNode {
    let titleNode = ASTextNode()

    init(title: String) {
        super.init()
        automaticallyManagesSubnodes = true
        titleNode.attributedText = NSAttributedString(
            string: title,
            attributes: [NSForegroundColorAttributeName: UIColor.white,
                         NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
        )
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        titleNode.style.flexShrink = 1
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets(
                top: CGFloat.infinity,
                left: 10,
                bottom: CGFloat.infinity,
                right: 10
            ),
            child: titleNode
        )
    }
}

class AutocompleteController: NSObject {
    var autocompleteQueries = ["проспект Победы",
                               "проспект Мира",
                               "проспект Степана Бандеры"]
    let parentNode: ASDisplayNode

    lazy var tableNode: ASTableNode = {
        let node = ASTableNode(style: .plain)

        node.dataSource = self
        node.delegate = self
        node.view.separatorStyle = .none
        node.backgroundColor = UIColor(hexString: "12171D",
                                       alpha: 0.86)
        return node
    }()

    var isShowing = false
    var onSelect: ((String) -> ())?

    init(parentNode: ASDisplayNode) {
        self.parentNode = parentNode
        super.init()
    }

    func showAutocomplete(for node: ASDisplayNode) {
        tableNode.reloadData()

        guard !isShowing else {
            return
        }
        
        tableNode.removeFromSupernode()
        parentNode.addSubnode(tableNode)
        isShowing = true
        tableNode.frame = CGRect(
            x: node.frame.origin.x,
            y: node.frame.origin.y + node.frame.height + 1,
            width: node.frame.width,
            height: 0
        )
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                let height = CGFloat(self.autocompleteQueries.count) * 30
                self.tableNode.frame.size.height = height <= 150 ? height : 150
        }, completion: nil)
    }

    func hideAutocomplete() {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.tableNode.frame.size.height = 0
        }, completion: { _ in
            self.tableNode.removeFromSupernode()
            self.isShowing = false
        })
    }
}

extension AutocompleteController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode,
                   numberOfRowsInSection section: Int) -> Int {
        return autocompleteQueries.count
    }

    func tableNode(_ tableNode: ASTableNode,
                   nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            return AutocompleteCellNode(title: self.autocompleteQueries[indexPath.row])
        }
    }

    func tableNode(_ tableNode: ASTableNode,
                   constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(
            CGSize(
                width: tableNode.bounds.width,
                height: 30
            )
        )
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let selectedText = autocompleteQueries[indexPath.row]

        onSelect?(selectedText)
    }
}
