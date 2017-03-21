//
//  RouteMapDisplayNode+MapHandling.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/17/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import GoogleMaps

extension RouteMapDisplayNode {
    func initPanorama() {
        if let routeOriginCoordinates = self.route.directions?.legs
            .first?.startLocationCoordinates {
            panoramaView.moveNearCoordinate(
                CLLocationCoordinate2D(
                    latitude: routeOriginCoordinates.0,
                    longitude: routeOriginCoordinates.1
                )
            )
        }
    }

    func initMarkers() {
        guard let routeOriginCoordinates = route.directions?
            .legs.first?.startLocationCoordinates,
            let routeDestinationCoordinates = route.directions?
                .legs.first?.endLocationCoordinates else {
                    return
        }

        carMarker = GMSMarker(
            position: CLLocationCoordinate2D(
                latitude: routeOriginCoordinates.0,
                longitude: routeOriginCoordinates.1
            )
        )
        carMarker.icon = #imageLiteral(resourceName: "ic_car_marker")
        carMarker.title = NSLocalizedString("map.car_marker_title", comment: "")
        carMarker.map = mapView
        carMarker.zIndex = 5
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
        guard let encodedRoutePath = route.directions?.overviewPolyline,
            let path = GMSPath(fromEncodedPath: encodedRoutePath) else {
                return
        }
        var bounds = GMSCoordinateBounds()

        bounds = bounds.includingPath(path)

        let update = GMSCameraUpdate.fit(bounds)

        mapView.animate(with: update)
    }

    func zoomToSegment(at index: Int, completion: (() -> ())? = nil) {
        guard let steps = route.directions?.legs.first?.steps,
            index < steps.count else {
                return
        }

        let polylinePath = GMSPath(fromEncodedPath: steps[index].polyline)!
        var bounds = GMSCoordinateBounds()

        bounds = bounds.includingPath(polylinePath)

        let update = GMSCameraUpdate.fit(bounds)

        CATransaction.begin()
        CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        mapView.animate(with: update)
        CATransaction.commit()

        let segmentEndLocation = CLLocationCoordinate2D(
            latitude: steps[index].endLocationLatitude,
            longitude: steps[index].endLocationLongitude
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.panoramaView.delegate = nil
            CATransaction.begin()
            CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
            CATransaction.setCompletionBlock({
                self.panoramaView.delegate = self
                completion?()
            })
            self.mapView.animate(
                to: GMSCameraPosition(
                    target: segmentEndLocation,
                    zoom: 18,
                    bearing: 0,
                    viewingAngle: 0
                )
            )
            self.carMarker.position = segmentEndLocation
            self.panoramaView.moveNearCoordinate(segmentEndLocation)
            CATransaction.commit()
        }
    }

    func showNextSegmentAndZoom(segmentIndex: Int) {
        guard let steps = route.directions?.legs.first?.steps,
            segmentIndex < steps.count else {
                return
        }

        let polylinePath = GMSPath(fromEncodedPath: steps[segmentIndex].polyline)
        let polyline = GMSPolyline(path: polylinePath)

        polyline.strokeColor =
            routePolylineSegmentsColors[segmentIndex % routePolylineSegmentsColors.count]
        polyline.strokeWidth = 3
        polyline.map = mapView
        switch mode {
        case .testing:
            zoomToSegment(at: segmentIndex, completion: {
                self.showAnswerButtons()
            })
        case .practice:
            zoomToSegment(at: segmentIndex)
        }
    }
    
    func zoomToCoordinate(_ coordinate: CLLocationCoordinate2D) {
        mapView.animate(toLocation: coordinate)
    }
}

extension RouteMapDisplayNode: GMSPanoramaViewDelegate {
    func panoramaView(_ view: GMSPanoramaView,
                      didMoveTo panorama: GMSPanorama?) {
        guard let panorama = panorama,
            syncCarMarkerToPanoramaPosition else {
                return
        }

        CATransaction.begin()
        CATransaction.setValue(1, forKey: kCATransactionAnimationDuration)
        carMarker.position = panorama.coordinate
        CATransaction.commit()
    }
}
