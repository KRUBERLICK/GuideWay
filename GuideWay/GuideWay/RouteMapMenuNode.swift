//
//  RouteMapMenuNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/14/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteMapMenuNode: ASDisplayNode {
    lazy var openMenuButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setImage(#imageLiteral(resourceName: "ic_menu_circle"), for: [])
        node.addTarget(
            self,
            action: #selector(RouteMapMenuNode.openMenuButtonTapped),
            forControlEvents: .touchUpInside
        )
        return node
    }()

    lazy var closeMenuButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setImage(#imageLiteral(resourceName: "ic_menu_close_circle"), for: [])
        node.addTarget(
            self,
            action: #selector(RouteMapMenuNode.closeMenuButtonTapped),
            forControlEvents: .touchUpInside
        )
        return node
    }()

    lazy var viewModeButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setImage(#imageLiteral(resourceName: "ic_menu_view_mode_circle"), for: [])
        node.addTarget(
            self,
            action: #selector(RouteMapMenuNode.viewModeButtonTapped),
            forControlEvents: .touchUpInside
        )
        return node
    }()

    lazy var nextButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setImage(#imageLiteral(resourceName: "ic_menu_next_circle"), for: [])
        node.addTarget(
            self,
            action: #selector(RouteMapMenuNode.nextButtonTapped),
            forControlEvents: .touchUpInside
        )
        return node
    }()

    lazy var infoButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setImage(#imageLiteral(resourceName: "ic_menu_info_circle"), for: [])
        node.addTarget(
            self,
            action: #selector(RouteMapMenuNode.infoButtonTapped),
            forControlEvents: .touchUpInside
        )
        return node
    }()

    lazy var exitButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setImage(#imageLiteral(resourceName: "ic_menu_exit_circle"), for: [])
        node.addTarget(
            self,
            action: #selector(RouteMapMenuNode.exitButtonTapped),
            forControlEvents: .touchUpInside
        )
        return node
    }()

    var isOpen = false {
        didSet {
            transitionLayout(withAnimation: true,
                             shouldMeasureAsync: true,
                             measurementCompletion: nil)
        }
    }

    var onViewModeButtonTap: (() -> ())?
    var onNextButtonTap: (() -> ())?
    var onInfoButtonTap: (() -> ())?
    var onExitButtonTap: (() -> ())?

    var isNextButtonEnabled = true

    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .clear
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let children = isOpen
            ? (isNextButtonEnabled
                ? [closeMenuButtonNode,
                   viewModeButtonNode,
                   nextButtonNode,
                   infoButtonNode,
                   exitButtonNode]
                : [closeMenuButtonNode,
                   viewModeButtonNode,
                   infoButtonNode,
                   exitButtonNode])
            : [openMenuButtonNode]
        let buttonsStack =  ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 3,
            justifyContent: .start, 
            alignItems: .end, 
            children: children
        )
        let insets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), 
            child: buttonsStack
        )

        return insets
    }

    func openMenuButtonTapped() {
        isOpen = true
    }

    func closeMenuButtonTapped() {
        isOpen = false
    }

    func viewModeButtonTapped() {
        onViewModeButtonTap?()
    }

    func nextButtonTapped() {
        onNextButtonTap?()
    }

    func infoButtonTapped() {
        onInfoButtonTap?()
    }

    func exitButtonTapped() {
        onExitButtonTap?()
    }

    override func point(inside point: CGPoint,
                        with event: UIEvent?) -> Bool {
        return openMenuButtonNode.frame.contains(point)
            || closeMenuButtonNode.frame.contains(point)
            || viewModeButtonNode.frame.contains(point)
            || nextButtonNode.frame.contains(point)
            || infoButtonNode.frame.contains(point)
            || exitButtonNode.frame.contains(point)
    }
}
