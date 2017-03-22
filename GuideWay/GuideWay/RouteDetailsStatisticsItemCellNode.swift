//
//  RouteDetailsStatisticsItemCellNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/21/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit
import Foundation

class RouteDetailsStatisticsItemCellNode: ASCellNode {
    let route: Route
    let passIndex: Int
    var onShowDetailsTap: ((Route) -> ())?

    lazy var persentTextNode: ASTextNode = {
        guard let routeSegmentsCount = self.route.directions?
            .legs.first?.steps.count else {
                return ASTextNode()
        }
        let node = ASTextNode()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor(hexString: "4990E2"), 
            NSFontAttributeName: UIFont.systemFont(
                ofSize: 50,
                weight: UIFontWeightUltraLight
            )
        ]
        var persents = Double(
            routeSegmentsCount
                - self.route.passes[self.passIndex].mistakeIndexes.count
            )
            / Double(routeSegmentsCount) * 100.0

        persents = round(persents)
        node.attributedText = NSAttributedString(
            string: "\(Int(persents))%",
            attributes: textAttribs
        )
        return node
    }()

    lazy var completedTextNode: ASTextNode = {
        let node = ASTextNode()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor(hexString: "E7E7E7"), 
            NSFontAttributeName: UIFont.systemFont(
                ofSize: 20,
                weight: UIFontWeightUltraLight
            )
        ]

        node.attributedText = NSAttributedString(
            string: NSLocalizedString("route_details.completed_label", comment: ""), 
            attributes: textAttribs
        )
        return node
    }()

    lazy var verticalSeparatorNode: ASDisplayNode = {
        let node = ASDisplayNode()

        node.backgroundColor = UIColor(white: 1, alpha: 0.15)
        return node
    }()

    lazy var maneuveursCountTextNode: ASTextNode = {
        guard let routeSegmentsCount = self.route.directions?
            .legs.first?.steps.count else {
                return ASTextNode()
        }
        let node = ASTextNode()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor(hexString: "F6A623"), 
            NSFontAttributeName: UIFont.systemFont(
                ofSize: 30, 
                weight: UIFontWeightUltraLight
            )
        ]

        node.attributedText = NSAttributedString(
            string: "\(routeSegmentsCount - self.route.passes[self.passIndex].mistakeIndexes.count) "
                + NSLocalizedString("route_details.of_label", comment: "") 
                + " \(routeSegmentsCount)",
            attributes: textAttribs
        )
        return node
    }()

    lazy var maneuveursDoneRightTextNode: ASTextNode = {
        let node = ASTextNode()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor(hexString: "C0C0C0"), 
            NSFontAttributeName: UIFont.systemFont(ofSize: 12)
        ]

        node.attributedText = NSAttributedString(
            string: NSLocalizedString("route_details.maneuveurs_done_right", comment: ""), 
            attributes: textAttribs
        )
        return node
    }()

    lazy var showDetailsButton: ASButtonNode = {
        let node = ASButtonNode()

        node.backgroundColor = UIColor(hexString: "8A8A8A")

        let textAttribs = [
            NSForegroundColorAttributeName: UIColor(hexString: "4A4A4A"), 
            NSFontAttributeName: UIFont.systemFont(ofSize: 12)
        ]
        node.setAttributedTitle(
            NSAttributedString(
                string: NSLocalizedString("route_details.statistics_show_details", comment: ""), 
                attributes: textAttribs
            ),
            for: []
        )
        node.addTarget(
            self, 
            action: #selector(RouteDetailsStatisticsItemCellNode.showDetailsButtonTapped), 
            forControlEvents: .touchUpInside
        )
        return node
    }()

    lazy var dateTextNode: ASTextNode = {
        let node = ASTextNode()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor(hexString: "C0C0C0"), 
            NSFontAttributeName: UIFont.systemFont(ofSize: 12)
        ]
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        let routePassDate = Date(
            timeIntervalSince1970: self.route.passes[self.passIndex].timestamp
        )
        let dateString = dateFormatter.string(from: routePassDate)

        node.attributedText = NSAttributedString(
            string: dateString,
            attributes: textAttribs
        )
        return node
    }()

    lazy var backgroundNode: ASDisplayNode = {
        let node = ASDisplayNode()

        node.backgroundColor = UIColor(hexString: "6B6B6B")
        node.cornerRadius = 5
        return node
    }()

    init(route: Route, passIndex: Int) {
        self.route = route
        self.passIndex = passIndex
        super.init()
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let persentsCompletedStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 0, 
            justifyContent: .center, 
            alignItems: .center, 
            children: [persentTextNode, completedTextNode]
        )
        let maneuveursDoneRightStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 0, 
            justifyContent: .center, 
            alignItems: .center, 
            children: [maneuveursCountTextNode, maneuveursDoneRightTextNode]
        )

        showDetailsButton.style.preferredSize = CGSize(width: 127, height: 40)

        let maneuveursDontRightAndButtonStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 9, 
            justifyContent: .center, 
            alignItems: .center, 
            children: [maneuveursDoneRightStack, showDetailsButton]
        )
        let addDateStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 20,
            justifyContent: .center,
            alignItems: .end, 
            children: [maneuveursDontRightAndButtonStack, dateTextNode]
        )

        verticalSeparatorNode.style.preferredSize = CGSize(
            width: 1 / UIScreen.main.scale, 
            height: 50
        )

        let verticalSeparatorNodeCentered = ASCenterLayoutSpec(
            centeringOptions: .XY, 
            sizingOptions: .minimumXY, 
            child: verticalSeparatorNode
        )
        let finalStack = ASStackLayoutSpec(
            direction: .horizontal, 
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center, 
            children: [persentsCompletedStack,
                       addDateStack]
        )
        let finalStackInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10),
            child: finalStack
        )
        let backgroundNodeBack = ASBackgroundLayoutSpec(
            child: finalStackInsets, 
            background: backgroundNode
        )
        let verticalSeparatorOverlay = ASOverlayLayoutSpec(
            child: backgroundNodeBack, 
            overlay: verticalSeparatorNodeCentered
        )
        let backgroundNodeBackInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 15),
            child: verticalSeparatorOverlay
        )

        return backgroundNodeBackInsets
    }

    override func layout() {
        super.layout()
        showDetailsButton.layer.shadowOpacity = 0.1
        showDetailsButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        showDetailsButton.layer.shadowColor = UIColor.black.cgColor
        showDetailsButton.layer.shadowRadius = 4
    }

    func showDetailsButtonTapped() {
        print(123)
        onShowDetailsTap?(route)
    }
}
