//
//  DirectionsResponse.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/1/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import ObjectMapper

enum RouteManeuver: String {
    case forkLeft = "fork-left"
    case forkRight = "fork-right"
    case merge = "merge"
    case rampLeft = "ramp-left"
    case rampRight = "ramp-right"
    case roundaboutLeft = "roundabout-left"
    case roundaboutRight = "roundabout-right"
    case straight = "straight"
    case turnLeft = "turn-left"
    case turnRight = "turn-right"
    case turnSharpLeft = "turn-sharp-left"
    case turnSharpRight = "turn-sharp-right"
    case turnSlightLeft = "turn-slight-left"
    case turnSlightRight = "turn-slight-right"
}

struct DirectionsResponseRouteLegStep: ImmutableMappable {
    let distanceText: String
    let distanceValue: Int
    let durationText: String
    let durationValue: Int
    let htmlInstructions: String
    let polyline: String
    let startLocationLatitude: Double
    let startLocationLongitude: Double
    let endLocationLatitude: Double
    let endLocationLongitude: Double
    var maneuver: RouteManeuver?

    var startLocationCoordinates: (Double, Double) {
        return (startLocationLatitude, startLocationLongitude)
    }

    var endLocationCoordinates: (Double, Double) {
        return (endLocationLatitude, endLocationLongitude)
    }

    init(map: Map) throws {
        distanceText = try map.value("distance.text")
        distanceValue = try map.value("distance.value")
        durationText = try map.value("duration.text")
        durationValue = try map.value("duration.value")
        htmlInstructions = try map.value("html_instructions")
        polyline = try map.value("polyline.points")
        startLocationLatitude = try map.value("start_location.lat")
        startLocationLongitude = try map.value("start_location.lng")
        endLocationLatitude = try map.value("end_location.lat")
        endLocationLongitude = try map.value("end_location.lng")
        maneuver = try? map.value("maneuver", using: EnumTransform())
    }

    mutating func mapping(map: Map) {
        distanceText >>> map["distance.text"]
        distanceValue >>> map["distance.value"]
        durationText >>> map["duration.text"]
        durationValue >>> map["duration.value"]
        htmlInstructions >>> map["html_instructions"]
        polyline >>> map["polyline.points"]
        startLocationLatitude >>> map["start_location.lat"]
        startLocationLongitude >>> map["start_location.lng"]
        endLocationLatitude >>> map["end_location.lat"]
        endLocationLongitude >>> map["end_location.lng"]
        maneuver <- (map["maneuver"], EnumTransform())
    }
}

struct DirectionsResponseRouteLeg: ImmutableMappable {
    let distanceString: String
    let distanceValue: Int
    let durationString: String
    let durationValue: Int
    let startLocationTitle: String
    let endLocationTitle: String
    let startLocationLatitude: Double
    let startLocationLongitude: Double
    let endLocationLatitude: Double
    let endLocationLongitude: Double
    let steps: [DirectionsResponseRouteLegStep]

    var startLocationCoordinates: (Double, Double) {
        return (startLocationLatitude, startLocationLongitude)
    }

    var endLocationCoordinates: (Double, Double) {
        return (endLocationLatitude, endLocationLongitude)
    }

    init(map: Map) throws {
        distanceString = try map.value("distance.text")
        distanceValue = try map.value("distance.value")
        durationString = try map.value("duration.text")
        durationValue = try map.value("duration.value")
        startLocationTitle = try map.value("start_address")
        endLocationTitle = try map.value("end_address")
        startLocationLatitude = try map.value("start_location.lat")
        startLocationLongitude = try map.value("start_location.lng")
        endLocationLatitude = try map.value("end_location.lat")
        endLocationLongitude = try map.value("end_location.lng")
        steps = try map.value("steps")
    }

    mutating func mapping(map: Map) {
        distanceString >>> map["distance.text"]
        distanceValue >>> map["distance.value"]
        durationString >>> map["duration.text"]
        durationValue >>> map["duration.value"]
        startLocationLatitude >>> map["start_location.lat"]
        startLocationLongitude >>> map["start_location.lng"]
        endLocationLatitude >>> map["end_location.lat"]
        endLocationLongitude >>> map["end_location.lng"]
        steps >>> map["steps"]
    }
}

struct DirectionsResponseRoute: ImmutableMappable {
    let overviewPolyline: String
    let legs: [DirectionsResponseRouteLeg]

    init(map: Map) throws {
        overviewPolyline = try map.value("overview_polyline.points")
        legs = try map.value("legs")
    }

    mutating func mapping(map: Map) {
        overviewPolyline >>> map["overview_polyline.points"]
        legs >>> map["legs"]
    }
}

struct DirectionsResponse: ImmutableMappable {
    let routes: [DirectionsResponseRoute]

    init(map: Map) throws {
        routes = try map.value("routes")
    }

    mutating func mapping(map: Map) {
        routes >>> map["routes"]
    }
}
