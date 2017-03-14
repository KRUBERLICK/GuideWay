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
    enum State {
        case split
        case mapOnly
        case panoramaOnly
    }

    let route: Route
    let mapView = GMSMapView()

    var state: State = .split {
        didSet {
            transitionLayout(withAnimation: true,
                             shouldMeasureAsync: true,
                             measurementCompletion: nil)
        }
    }

    lazy var mapNode: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [unowned self] in self.mapView })
    }()

    lazy var menuNode: RouteMapMenuNode = {
        let node = RouteMapMenuNode()

        node.onViewModeButtonTap = { [unowned self] in
            self.changeViewMode()
        }
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

        if state == .split {
            mapNode.style.flexBasis =
                ASDimensionMakeWithFraction(isLandscape ? 0.5 : 0.4)
            panoramaNode.style.flexBasis =
                ASDimensionMakeWithFraction(isLandscape ? 0.5 : 0.6)
        } else {
            mapNode.style.flexBasis = ASDimensionMakeWithFraction(1)
            panoramaNode.style.flexBasis = ASDimensionMakeWithFraction(1)
        }

        var children: [ASDisplayNode]

        switch state {
        case .split:
            children = [panoramaNode, mapNode]
        case .mapOnly:
            children = [mapNode]
        case .panoramaOnly:
            children = [panoramaNode]
        }

        let mapAndPanoramaStack = ASStackLayoutSpec(
            direction: isLandscape ? .horizontal : .vertical, 
            spacing: 0, 
            justifyContent: .start, 
            alignItems: .stretch, 
            children: children
        )
        let menuOverlay = ASOverlayLayoutSpec(
            child: mapAndPanoramaStack, 
            overlay: menuNode
        )

        return menuOverlay
    }

    func changeViewMode() {
        switch state {
        case .split:
            state = .panoramaOnly
        case .mapOnly:
            state = .split
        case .panoramaOnly:
            state = .mapOnly
        }
    }
}
