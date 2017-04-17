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
    let mode: RouteMapViewController.Mode
    var mapView: GMSMapView!
    let routePolylineSegmentsColors = [UIColor(hexString: "4A90E2"), 
                                       UIColor(hexString: "21C064"),
                                       UIColor(hexString: "50E3C2"),
                                       UIColor(hexString: "F8832B")]

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
        node.onInfoButtonTap = { [unowned self] in self.toggleInfoNode() }
        node.onNextButtonTap = { [unowned self] in self.onNextButtonTap?() }
        return node
    }()

    lazy var infoNode: RouteMapInfoNode = {
        let node = RouteMapInfoNode(route: self.route)

        node.onTextInstructionsButtonTap = { [unowned self] in self.onTextInstructionsButtonTap?() }
        node.onCloseButtonTap = { [unowned self] in self.toggleInfoNode() }
        return node
    }()

    lazy var finishButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setImage(#imageLiteral(resourceName: "ic_map_finish"), for: [])
        node.addTarget(self, 
                       action: #selector(RouteMapDisplayNode.finishButtonTapped), 
                       forControlEvents: .touchUpInside
        )
        return node
    }()

    lazy var answerRightButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setImage(#imageLiteral(resourceName: "ic_map_thumbs_up"), for: [])
        node.addTarget(
            self, 
            action: #selector(RouteMapDisplayNode.answerButtonTapped(sender:)), 
            forControlEvents: .touchUpInside
        )
        return node
    }()

    lazy var answerWrongButtonNode: ASButtonNode = {
        let node = ASButtonNode()

        node.setImage(#imageLiteral(resourceName: "ic_map_thumbs_down"), for: [])
        node.addTarget(
            self, 
            action: #selector(RouteMapDisplayNode.answerButtonTapped(sender:)), 
            forControlEvents: .touchUpInside
        )
        return node
    }()

    lazy var panoramaView: GMSPanoramaView = {
        guard let originCoordinates = self.route.directions?
            .legs.first?.startLocationCoordinates else {
                return GMSPanoramaView()
        }

        let panoramaView = GMSPanoramaView.panorama(
            withFrame: .zero, 
            nearCoordinate: CLLocationCoordinate2D(
                latitude: originCoordinates.0, 
                longitude: originCoordinates.1
            )
        )

        panoramaView.delegate = self
        return panoramaView
    }()

    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var carMarker: GMSMarker!

    var isNextButtonDisabled: Bool = false {
        didSet {
            menuNode.isNextButtonEnabled = !isNextButtonDisabled
            menuNode.transitionLayout(
                withAnimation: true, 
                shouldMeasureAsync: true, 
                measurementCompletion: nil
            )
        }
    }
    
    lazy var panoramaNode: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [unowned self] in self.panoramaView })
    }()

    var onNextButtonTap: (() -> ())?
    var onTextInstructionsButtonTap: (() -> ())?
    var onExitButtonTap: (() -> ())?
    var onFinishButtonTap: (() -> ())?
    var onAnswerRightButtonTap: (() -> ())?
    var onAnswerWrongButtonTap: (() -> ())?
    var syncCarMarkerToPanoramaPosition = true

    init(route: Route, 
         mode: RouteMapViewController.Mode) {
        self.route = route
        self.mode = mode
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .white
    }

    override func didLoad() {
        super.didLoad()
        mapView = GMSMapView()
        initMarkers()
        paintInitialRoutePolyline()
    }

    override func didEnterDisplayState() {
        super.didEnterDisplayState()
        zoomToInitial()
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
