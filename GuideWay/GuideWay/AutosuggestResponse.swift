//
//  AutosuggestResponse.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/23/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import ObjectMapper

struct AutosuggestItem: ImmutableMappable {
    let name: String
    let formattedAddress: String
    let latitude: Double
    let longitude: Double

    init(map: Map) throws {
        name = try map.value("name")
        formattedAddress = try map.value("formatted_address")
        latitude = try map.value("geometry.location.lat")
        longitude = try map.value("geometry.location.lng")
    }

    mutating func mapping(map: Map) {
        name >>> map["name"]
        formattedAddress >>> map["formatted_address"]
        latitude >>> map["geometry.location.lat"]
        longitude >>> map["geometry.location.lng"]
    }
}

struct AutosuggestResponse: ImmutableMappable {
    let results: [AutosuggestItem]

    init(map: Map) throws {
        results = try map.value("results")
    }

    mutating func mapping(map: Map) {
        results >>> map["results"]
    }
}
