//
//  RouteManeuversListDisplayNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/27/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteManeuversListDisplayNode: ASDisplayNode {
    let presentationManager: PresentationManager
    let route: Route
    let passIndex: Int?

    lazy var collectionNode: ASCollectionNode = {
        let layout = UICollectionViewFlowLayout()

        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 15

        let cn = ASCollectionNode(collectionViewLayout: layout)

        cn.dataSource = self
        cn.delegate = self
        cn.backgroundColor = UIColor(hexString: "D7E2F0")
        return cn
    }()
    
    init(presentationManager: PresentationManager,
         route: Route, 
         passIndex: Int? = nil) {
        self.presentationManager = presentationManager
        self.route = route
        self.passIndex = passIndex
        super.init()
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASCenterLayoutSpec(
            centeringOptions: .XY,
            sizingOptions: .minimumXY, 
            child: collectionNode
        )
    }
}

extension RouteManeuversListDisplayNode: ASCollectionDataSource, ASCollectionDelegate, ASCollectionDelegateFlowLayout {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode,
                        numberOfItemsInSection section: Int) -> Int {
        guard let steps = route.directions?.legs.first?.steps,
            !steps.isEmpty else {
                return 0
        }
        
        return steps.count
    }

    func collectionNode(_ collectionNode: ASCollectionNode,
                        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let steps = route.directions?.legs.first?.steps,
            !steps.isEmpty else {
                return { ASCellNode() }
        }

        let maneuverText = steps[indexPath.item].htmlInstructions
        let maneuverType = steps[indexPath.item].maneuver
        var isFailed = false

        if let passIndex = passIndex, route.passes[passIndex]
            .mistakeIndexes.contains(indexPath.item) {
            isFailed = true
        }

        let cellNode = presentationManager.getRouteManeuverCellNode(
            maneuverText: maneuverText, 
            maneuverType: maneuverType,
            isFailed: isFailed
        )

        return { cellNode }
    }

    func collectionNode(_ collectionNode: ASCollectionNode,
                        constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let width = collectionNode.bounds.width - 24 * 2
        let minSize = CGSize(width: width, height: 0)
        let maxSize = CGSize(width: width, height: CGFloat.infinity)

        return ASSizeRange(min: minSize, max: maxSize)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
    }
}
