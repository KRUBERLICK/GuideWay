//
//  RouteDetailsDisplayNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/24/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteDetailsDisplayNode: ASDisplayNode {
    enum State {
        case loading
        case loadingFailed
        case noDirections
        case loaded(Route)
    }

    var state: State {
        didSet {
            transitionLayout(
                withAnimation: true, 
                shouldMeasureAsync: true, 
                measurementCompletion: nil
            )
        }
    }

    var onPracticeTap: (() -> ())?
    var onTestTap: (() -> ())?

    let backgroundNode: ASImageNode = {
        let node = ASImageNode()

        node.image = #imageLiteral(resourceName: "img_route_details_bg")
        node.contentMode = .scaleAspectFill
        return node
    }()

    lazy var collectionNode: ASCollectionNode = {
        let node = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())

        node.backgroundColor = .clear
        node.dataSource = self
        node.delegate = self
        return node
    }()

    lazy var practiceButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        let titleAttribs = [NSForegroundColorAttributeName: UIColor.white, 
                            NSFontAttributeName: UIFont.systemFont(ofSize: 20)]

        node.setImage(#imageLiteral(resourceName: "ic_practice"), for: [])
        node.setAttributedTitle(
            NSAttributedString(
                string: NSLocalizedString("route_details.practice", comment: ""), 
                attributes: titleAttribs
            ),
            for: []
        )
        node.addTarget(
            self, 
            action: #selector(RouteDetailsDisplayNode.practiceButtonTapped),
            forControlEvents: .touchUpInside
        )
        node.backgroundColor = UIColor(hexString: "4990E2")
        return node
    }()

    lazy var testButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        let titleAttribs = [NSForegroundColorAttributeName: UIColor.white, 
                            NSFontAttributeName: UIFont.systemFont(ofSize: 20)]

        node.setImage(#imageLiteral(resourceName: "ic_test"), for: [])
        node.setAttributedTitle(
            NSAttributedString(
                string: NSLocalizedString("route_details.test", comment: ""), 
                attributes: titleAttribs
            ),
            for: []
        )
        node.addTarget(
            self, 
            action: #selector(RouteDetailsDisplayNode.testButtonTapped), 
            forControlEvents: .touchUpInside
        )
        node.backgroundColor = UIColor(hexString: "21C064")
        return node
    }()

    let verticalLineNode: ASDisplayNode = {
        let node = ASDisplayNode()

        node.backgroundColor = UIColor(hexString: "1C4C84", alpha: 0.4)
        return node
    }()

    let loadingTextNode: ASTextNode = {
        let node = ASTextNode()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor.white, 
            NSFontAttributeName: UIFont.systemFont(ofSize: 20)
        ]

        node.attributedText = NSAttributedString(
            string: NSLocalizedString("route_details.loading_route", comment: ""), 
            attributes: textAttribs
        )
        return node
    }()

    let errorTextNode: ASTextNode = {
        let node = ASTextNode()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor.white, 
            NSFontAttributeName: UIFont.systemFont(ofSize: 20)
        ]

        node.attributedText = NSAttributedString(
            string: NSLocalizedString("route_details.loading_failed", comment: ""), 
            attributes: textAttribs
        )
        return node
    }()

    let noDirectionsTextNode: ASTextNode = {
        let node = ASTextNode()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.systemFont(ofSize: 20)
        ]

        node.attributedText = NSAttributedString(
            string: NSLocalizedString("route_details.no_directions", comment: ""),
            attributes: textAttribs
        )
        return node
    }()

    let presentationManager: PresentationManager

    var isEditing: Bool = false {
        didSet {
            guard case .loaded(_) = state else {
                return
            }

            collectionNode.reloadItems(at: [IndexPath(item: 0, section: 0)])
        }
    }

    var currentRouteTitle: String? {
        return (collectionNode.nodeForItem(
            at: IndexPath(item: 0,
                          section: 0))
            as? RouteDetailsTitleCellNode)?
            .titleTextField.text
    }

    init(presentationManager: PresentationManager, state: State) {
        self.presentationManager = presentationManager
        self.state = state
        super.init()
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        switch state {
        case .loading:
            return loadingLayoutSpec()
        case .loadingFailed:
            return loadingFailedLayoutSpec()
        case .noDirections:
            return noDirectionsLayoutSpec()
        case .loaded(_):
            return loadedRouteLayoutSpec()
        }
    }

    func loadedRouteLayoutSpec() -> ASLayoutSpec {
        practiceButtonNode.style.flexBasis = ASDimensionMakeWithFraction(0.5)
        testButtonNode.style.flexBasis = ASDimensionMakeWithFraction(0.5)

        let bottomButtonsStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .start,
            alignItems: .stretch,
            children: [practiceButtonNode,
                       testButtonNode]
        )

        bottomButtonsStack.style.flexBasis = ASDimensionMake(50)
        collectionNode.style.flexGrow = 1
        collectionNode.style.flexShrink = 1

        let collectionNodeAndBottomButtonsStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .stretch,
            children: [collectionNode,
                       bottomButtonsStack]
        )

        verticalLineNode.style.preferredSize = CGSize(width: 2, height: 50)

        let verticalLineNodeInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(
                top: CGFloat.infinity,
                left: CGFloat.infinity,
                bottom: 0,
                right: CGFloat.infinity
            ),
            child: verticalLineNode
        )
        let verticalLineOverlay = ASOverlayLayoutSpec(
            child: collectionNodeAndBottomButtonsStack,
            overlay: verticalLineNodeInsets
        )
        let backgroundNodeOverlay = ASOverlayLayoutSpec(
            child: backgroundNode,
            overlay: verticalLineOverlay
        )
        
        return backgroundNodeOverlay
    }

    func loadingLayoutSpec() -> ASLayoutSpec {
        return ASOverlayLayoutSpec(
            child: backgroundNode, 
            overlay: ASCenterLayoutSpec(
                centeringOptions: .XY, 
                sizingOptions: .minimumXY, 
                child: loadingTextNode
            )
        )
    }

    func loadingFailedLayoutSpec() -> ASLayoutSpec {
        return ASOverlayLayoutSpec(
            child: backgroundNode,
            overlay: ASCenterLayoutSpec(
                centeringOptions: .XY,
                sizingOptions: .minimumXY,
                child: errorTextNode
            )
        )
    }

    func noDirectionsLayoutSpec() -> ASLayoutSpec {
        return ASOverlayLayoutSpec(
            child: backgroundNode, 
            overlay: ASCenterLayoutSpec(
                centeringOptions: .XY, 
                sizingOptions: .minimumXY, 
                child: noDirectionsTextNode
            )
        )
    }

    func practiceButtonTapped() {
        onPracticeTap?()
    }

    func testButtonTapped() {
        onTestTap?()
    }
}

extension RouteDetailsDisplayNode: ASCollectionDataSource, ASCollectionDelegateFlowLayout {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        guard case .loaded(_) = state else {
            return 0
        }

        return 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode,
                        numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionNode(_ collectionNode: ASCollectionNode, 
                        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        switch indexPath.section {
        case 0:
            switch indexPath.item {
            case 0:
                return constructRouteDetailsTitleCellNode()
            case 1:
                return constructRouteDetailsMapCellNode()
            default:
                return { ASCellNode() }
            }
        default:
            return { ASCellNode() }
        }
    }

    func collectionNode(_ collectionNode: ASCollectionNode,
                        constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let width = collectionNode.bounds.width
        let minSize = CGSize(width: width, height: 0)
        let maxSize = CGSize(width: width, height: CGFloat.infinity)

        return ASSizeRangeMake(minSize, maxSize)
    }

    func constructRouteDetailsTitleCellNode() -> ASCellNodeBlock {
        guard case let .loaded(route) = state else {
            return { ASCellNode() }
        }

        let routeTitle = route.title
        let editingMode = isEditing

        return {
            return routeTitle == nil
                ? self.presentationManager
                    .getRouteDetailsTitleCellNode(editingMode: editingMode)
                : self.presentationManager
                    .getRouteDetailsTitleCellNode(
                        with: routeTitle!, 
                        editingMode: editingMode
                )
        }
    }

    func constructRouteDetailsMapCellNode() -> ASCellNodeBlock {
        guard case let .loaded(route) = state else {
            return { ASCellNode() }
        }

        return {
            return self.presentationManager
                .getRouteDetailsMapCellNode(for: route)
        }
    }
}
