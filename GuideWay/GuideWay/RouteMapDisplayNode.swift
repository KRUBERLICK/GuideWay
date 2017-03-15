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
        node.onInfoButtonTap = { [unowned self] in self.onInfoButtonTap?() }
        node.onNextButtonTap = { [unowned self] in self.onNextButtonTap?() }
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

    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!

    var isRouteCompleted: Bool = false {
        didSet {
            menuNode.isNextButtonEnabled = !isRouteCompleted
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
    var onInfoButtonTap: (() -> ())?
    var onExitButtonTap: (() -> ())?
    var onFinishButtonTap: (() -> ())?

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

    func initMarkers() {
        guard let routeOriginCoordinates = route.directions?
            .legs.first?.startLocationCoordinates,
            let routeDestinationCoordinates = route.directions?
                .legs.first?.endLocationCoordinates else {
                return
        }

        originMarker = GMSMarker(
            position: CLLocationCoordinate2D(
                latitude: routeOriginCoordinates.0,
                longitude: routeOriginCoordinates.1
            )
        )
        destinationMarker = GMSMarker(
            position: CLLocationCoordinate2D(
                latitude: routeDestinationCoordinates.0,
                longitude: routeDestinationCoordinates.1
            )
        )
        originMarker.icon = #imageLiteral(resourceName: "ic_map_origin_no_shadow")
        originMarker.title = route.directions?.legs.first?.startLocationTitle
        originMarker.map = mapView
        destinationMarker.icon = #imageLiteral(resourceName: "ic_map_destination_no_shadow")
        destinationMarker.title = route.directions?.legs.first?.endLocationTitle
        destinationMarker.map = mapView
    }

    func paintInitialRoutePolyline() {
        switch mode {
        case .practice:
            guard let steps = route.directions?.legs.first?.steps else {
                return
            }

            for (index, step) in steps.enumerated() {
                let polylinePath = GMSPath(fromEncodedPath: step.polyline)
                let polyline = GMSPolyline(path: polylinePath)

                polyline.strokeColor =
                    routePolylineSegmentsColors[index % routePolylineSegmentsColors.count]
                polyline.strokeWidth = 4
                polyline.map = mapView
            }
        case .testing:
            guard let firstStep = route.directions?.legs.first?.steps.first else {
                return
            }

            let polylinePath = GMSPath(fromEncodedPath: firstStep.polyline)
            let polyline = GMSPolyline(path: polylinePath)

            polyline.strokeColor = routePolylineSegmentsColors[0]
            polyline.strokeWidth = 3
            polyline.map = mapView
        }
    }

    func zoomToInitial() {
        var bounds = GMSCoordinateBounds()

        bounds = bounds.includingCoordinate(originMarker.position)
        bounds = bounds.includingCoordinate(destinationMarker.position)

        let update = GMSCameraUpdate.fit(bounds)

        mapView.animate(with: update)
    }

    func zoomToSegment(at index: Int) {
        guard let steps = route.directions?.legs.first?.steps,
            index < steps.count else {
                return
        }

        let polylinePath = GMSPath(fromEncodedPath: steps[index].polyline)!
        var bounds = GMSCoordinateBounds()

        bounds = bounds.includingPath(polylinePath)

        let update = GMSCameraUpdate.fit(bounds)

        mapView.animate(with: update)
    }

    func showFinishButton() {
        let calculatedLayout = finishButtonNode.calculateLayoutThatFits(
            ASSizeRangeMake(
                .zero, 
                CGSize(width: CGFloat.infinity,
                       height: CGFloat.infinity)
            )
        )
        let origin = CGPoint(
            x: frame.midX - calculatedLayout.size.width / 2, 
            y: frame.maxY
        )

        finishButtonNode.frame = CGRect(origin: origin,
                                        size: calculatedLayout.size)
        addSubnode(finishButtonNode)
        UIView.animate(withDuration: 0.25,
                       delay: 0, 
                       options: .curveEaseOut, 
                       animations: {
                        self.finishButtonNode.frame.origin.y -=
                            self.finishButtonNode.bounds.height + 45
        }, completion: nil)
    }

    func hideFinishButton(completion: (() -> ())?) {
        UIView.animate(withDuration: 0.25,
                       delay: 0, 
                       options: .curveEaseIn, 
                       animations: {
                        self.finishButtonNode.frame.origin.y += 
                            self.finishButtonNode.bounds.height + 45
        }, completion: { _ in
            self.finishButtonNode.removeFromSupernode()
            completion?()
        })
    }

    func finishButtonTapped() {
        hideFinishButton { 
            self.onFinishButtonTap?()
        }
    }
}
