//
//  Route.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/24/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import ObjectMapper

struct Route: ImmutableMappable {
    var id: String?
    var title: String?
    var origin: String
    var destination: String
    var directions: DirectionsResponseRoute?
    var statistics: [[Int]]

    init(origin: String,
         destination: String) {
        id = nil
        self.origin = origin
        self.destination = destination
        self.directions = nil
        self.statistics = []
    }

    init(map: Map) throws {
        id = try? map.value("id")
        title = try? map.value("title")
        origin = try map.value("origin")
        destination = try map.value("destination")
        directions = try? map.value("directions")
        statistics = (try? map.value("statistics")) ?? []
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        origin <- map["origin"]
        destination <- map["destination"]
        directions <- map["directions"]
        statistics <- map["statistics"]
    }
}
