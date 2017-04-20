//
//  RoutesListDisplayNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 4/20/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RoutesListDisplayNode: ASDisplayNode {
    let collectionNode: ASCollectionNode

    override init() {
        let collectionViewLayout = UICollectionViewFlowLayout()

        collectionViewLayout.minimumLineSpacing = 20
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionNode = ASCollectionNode(collectionViewLayout: collectionViewLayout)
        collectionNode.backgroundColor = UIColor(hexString: "E4FCFF")
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
