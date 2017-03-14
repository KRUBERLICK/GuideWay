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

    init(route: Route) {
        self.route = route
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .white
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let isLandscape = constrainedSize.max.width > constrainedSize.max.height

        mapNode.style.flexBasis = ASDimensionMakeWithFraction(isLandscape ? 0.5 : 0.4)
        panoramaNode.style.flexBasis = ASDimensionMakeWithFraction(isLandscape ? 0.5 : 0.6)
//        panoramaNode.style.flexGrow = 1
//        mapNode.style.flexGrow = 1
        return ASStackLayoutSpec(direction: isLandscape ? .horizontal : .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [panoramaNode, mapNode])
    }
}
