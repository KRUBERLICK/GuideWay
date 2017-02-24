//
//  Route.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/24/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import ObjectMapper

struct Route: ImmutableMappable {
    let id: String
    var origin: String
    var destination: String
    var length: Double?
    var duration: Double?

    init(origin: String, destination: String) {
        self.origin = origin
        self.destination = destination
        id = ""
    }

    init(map: Map) throws {
        id = try map.value("id")
        origin = try map.value("origin")
        destination = try map.value("destination")
        length = try? map.value("length")
        duration = try? map.value("duration")
    }

    mutating func mapping(map: Map) {
        id >>> map["id"]
        origin <- map["origin"]
        destination <- map["destination"]
        length <- map["length"]
        duration <- map["duration"]
    }
}
