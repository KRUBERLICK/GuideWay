//
//  RouteMapDisplayNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/14/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit
import GoogleMaps

class RouteMapDisplayNode: ASDisplayNode {
    let route: Route
    let mapView = GMSMapView()

    lazy var mapNode: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [unowned self] in self.mapView })
    }()

    lazy var menuNode: RouteMapMenuNode = {
        let node = RouteMapMenuNode()

        node.onExitButtonTap = { [unowned self] in self.onExitButtonTap?() }
        node.onInfoButtonTap = { [unowned self] in self.onInfoButtonTap?() }
        node.onNextButtonTap = { [unowned self] in self.onNextButtonTap?() }
        return node
    }()

    var panoramaView: GMSPanoramaView {
        if let routeOriginCoordinates = route.directions?.legs
            .first?.startLocationCoordinates {
            return GMSPanoramaView.panorama(
                withFrame: .zero,
                nearCoordinate: CLLocationCoordinate2D(
                    latitude: routeOriginCoordinates.0,
                    longitude: routeOriginCoordinates.1
                )
            )
        }
        return GMSPanoramaView()
    }
    
    lazy var panoramaNode: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [unowned self] in self.panoramaView })
    }()

    var onNextButtonTap: (() -> ())?
    var onInfoButtonTap: (() -> ())?
    var onExitButtonTap: (() -> ())?

    init(route: Route) {
        self.route = route
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .white
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let isLandscape = constrainedSize.max.width > constrainedSize.max.height

        mapNode.style.flexBasis =
            ASDimensionMakeWithFraction(isLandscape ? 0.5 : 0.4)
        panoramaNode.style.flexBasis =
            ASDimensionMakeWithFraction(isLandscape ? 0.5 : 0.6)

        let mapAndPanoramaStack = ASStackLayoutSpec(
            direction: isLandscape ? .horizontal : .vertical, 
            spacing: 0, 
            justifyContent: .start, 
            alignItems: .stretch, 
            children: [panoramaNode, mapNode]
        )
        let menuOverlay = ASOverlayLayoutSpec(
            child: mapAndPanoramaStack, 
            overlay: menuNode
        )

        return menuOverlay
    }
}
