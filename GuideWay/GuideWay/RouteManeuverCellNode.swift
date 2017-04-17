//
//  RouteManeuverCellNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/27/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteManeuverCellNode: ASCellNode {
    let maneuverIconNode: ASImageNode = {
        let node = ASImageNode()

        node.clipsToBounds = true
        return node
    }()

    let maneuverTextNode: ASTextNode

    lazy var backgroundImageNode: ASImageNode = {
        let node = ASImageNode()
        let image = UIImage.as_resizableRoundedImage(
            withCornerRadius: 5,
            cornerColor: .clear,
            fill: self.isFailed ? UIColor(hexString: "FFE4E4") : .white
        )

        node.image = image
        return node
    }()

    let maneuverType: RouteManeuver?
    let isFailed: Bool

    init(maneuverText: String, 
         maneuverType: RouteManeuver?, 
         isFailed: Bool = false) {
        self.maneuverType = maneuverType
        self.isFailed = isFailed
        maneuverTextNode = ASTextNode()

        let textAttribs = [NSForegroundColorAttributeName: UIColor(hexString: "9B9B9B"),
                           NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        let attributedManeuverText = try? NSMutableAttributedString(
            data: maneuverText.data(using: .utf8)!,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                      NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        )

        attributedManeuverText?.addAttributes(
            textAttribs, 
            range: NSMakeRange(0, attributedManeuverText?.length ?? 0)
        )
        maneuverTextNode.attributedText = attributedManeuverText
        maneuverTextNode.maximumNumberOfLines = 0
        if let maneuverType = maneuverType {
            maneuverIconNode.image = UIImage(named: maneuverType.rawValue)
        }
        super.init()
        automaticallyManagesSubnodes = true
        clipsToBounds = false
    }

    override func layout() {
        super.layout()
        backgroundImageNode.layer.shadowColor = UIColor(white: 0, alpha: 0.2).cgColor
        backgroundImageNode.layer.shadowOffset = CGSize(width: 0, height: 2)
        backgroundImageNode.layer.shadowRadius = 4
        backgroundImageNode.layer.shadowOpacity = 1
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        maneuverTextNode.style.flexShrink = 1

        let iconAndTextStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 20,
            justifyContent: .start,
            alignItems: .center,
            children: maneuverType == nil
                ? [maneuverTextNode]
                : [maneuverIconNode, maneuverTextNode]
        )
        let iconAndTextStackInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
            child: iconAndTextStack
        )
        let background = ASBackgroundLayoutSpec(
            child: iconAndTextStackInsets,
            background: backgroundImageNode
        )
        
        return background
    }
}
