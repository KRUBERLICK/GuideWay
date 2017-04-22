//
//  Route.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/24/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import ObjectMapper

struct RoutePass: ImmutableMappable {
    let timestamp: Double
    let mistakeIndexes: [Int]

    init(mistakeIndexes: [Int] = []) {
        timestamp = Date().timeIntervalSince1970
        self.mistakeIndexes = mistakeIndexes
    }

    init(map: Map) throws {
        timestamp = try map.value("timestamp")
        mistakeIndexes = try map.value("mistake_indexes")
    }

    mutating func mapping(map: Map) {
        timestamp >>> map["timestamp"]
        mistakeIndexes >>> map["mistake_indexes"]
    }
}

struct Route: ImmutableMappable {
    var id: String?
    var title: String?
    var origin: String
    var destination: String
    var directions: DirectionsResponseRoute?
    var passes: [RoutePass] = []

    init(origin: String,
         destination: String) {
        id = nil
        self.origin = origin
        self.destination = destination
        self.directions = nil
        self.passes = []
    }

    init(map: Map) throws {
        id = try? map.value("id")
        title = try? map.value("title")
        origin = try map.value("origin")
        destination = try map.value("destination")
        directions = try? map.value("directions")
        passes = (try? map.value("passes")) ?? []
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        origin <- map["origin"]
        destination <- map["destination"]
        directions >>> map["directions"]
        passes >>> map["passes"]
    }
}
