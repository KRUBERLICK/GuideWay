//
//  RouteDetailsMapNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/1/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit
import GoogleMaps

class RouteDetailsMapCellNode: ASCellNode {
    var mapView: GMSMapView!

    lazy var mapNode: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [unowned self] in self.mapView })
    }()

    let durationIconNode: ASImageNode = {
        let node = ASImageNode()

        node.image = #imageLiteral(resourceName: "ic_duration")
        return node
    }()

    let distanceIconNode: ASImageNode = {
        let node = ASImageNode()

        node.image = #imageLiteral(resourceName: "ic_distance")
        return node
    }()

    let durationTextNode = ASTextNode()
    let distanceTextNode = ASTextNode()
    let route: Route
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var routePolyline: GMSPolyline!

    init(route: Route) {
        self.route = route
        super.init()
        automaticallyManagesSubnodes = true
    }

    override func didLoad() {
        super.didLoad()
        bindData()
    }

    func bindData() {
        mapView = GMSMapView()
        mapView.isUserInteractionEnabled = false

        guard let durationText = route.directions?.legs.first?.durationString, 
            let distanceText = route.directions?.legs.first?.distanceString else {
                return
        }

        let textAttribs = [
            NSForegroundColorAttributeName: UIColor.white, 
            NSFontAttributeName: UIFont.systemFont(ofSize: 14)
        ]

        durationTextNode.attributedText = NSAttributedString(
            string: durationText, 
            attributes: textAttribs
        )
        distanceTextNode.attributedText = NSAttributedString(
            string: distanceText, 
            attributes: textAttribs
        )

        guard let routeOriginCoordinates = route.directions?
            .legs.first?.startLocationCoordinates,
            let routeDestinationCoordinates = route.directions?
                .legs.first?.endLocationCoordinates,
            let overviewPolylineString = route.directions?
                .overviewPolyline else {
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
        routePolyline = GMSPolyline(path: GMSPath(fromEncodedPath: overviewPolylineString))
        routePolyline.strokeColor = UIColor(hexString: "4A90E2")
        routePolyline.strokeWidth = 3
        routePolyline.map = mapView
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        mapNode.cornerRadius = 5
        mapNode.clipsToBounds = true
        mapNode.style.preferredSize.width =
            constrainedSize.max.width - 56 > 0
            ? constrainedSize.max.width - 56
            : 0

        let mapNodeRatio = ASRatioLayoutSpec(ratio: 1/2, child: mapNode)
        let durationStack = ASStackLayoutSpec(
            direction: .horizontal, 
            spacing: 6, 
            justifyContent: .start, 
            alignItems: .center, 
            children: [durationIconNode, 
                       durationTextNode]
        )
        let distanceStack = ASStackLayoutSpec(
            direction: .horizontal, 
            spacing: 6, 
            justifyContent: .start, 
            alignItems: .center, 
            children: [distanceIconNode, 
                       distanceTextNode]
        )
        let durationAndDistanceStack = ASStackLayoutSpec(
            direction: .horizontal, 
            spacing: 0, 
            justifyContent: .spaceBetween, 
            alignItems: .center, 
            children: [durationStack, 
                       distanceStack]
        )
        let finalStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 6, 
            justifyContent: .start, 
            alignItems: .stretch, 
            children: [mapNodeRatio, 
                       durationAndDistanceStack]
        )
        let finalStackInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 28, bottom: 33, right: 28), 
            child: finalStack
        )

        return finalStackInsets
    }

    override func didEnterDisplayState() {
        super.didEnterDisplayState()

        if let path = routePolyline.path {
            zoomMapToFit(path: path)
        }
    }

    func zoomMapToFit(_ coords: [CLLocationCoordinate2D]) {
        var bounds = GMSCoordinateBounds()

        coords.forEach { bounds = bounds.includingCoordinate($0) }
        mapView.animate(
            with: GMSCameraUpdate.fit(
                bounds,
                with: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            )
        )
    }

    func zoomMapToFit(path: GMSPath) {
        var bounds = GMSCoordinateBounds()

        bounds = bounds.includingPath(path)
        mapView.animate(
            with: GMSCameraUpdate.fit(
                bounds,
                with: UIEdgeInsets(top: 30 + 5, left: 12 + 5, bottom: 5, right: 12 + 5)
            )
        )
    }
}
