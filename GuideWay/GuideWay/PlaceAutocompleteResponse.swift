//
//  AutosuggestResponse.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/23/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import ObjectMapper

struct PlaceAutocompleteResponseItemTerm: ImmutableMappable {
    let offset: Int
    let value: String

    init(map: Map) throws {
        offset = try map.value("offset")
        value = try map.value("value")
    }

    mutating func mapping(map: Map) {
        offset >>> map["offset"]
        value >>> map["value"]
    }
}

struct PlaceAutocompleteResponseItem: ImmutableMappable {
    let id: String
    let description: String
    let terms: [PlaceAutocompleteResponseItemTerm]

    init(map: Map) throws {
        id = try map.value("id")
        description = try map.value("description")
        terms = try map.value("terms")
    }

    mutating func mapping(map: Map) {
        id >>> map["id"]
        description >>> map["description"]
        terms >>> map["terms"]
    }
}

struct PlaceAutocompleteResponse: ImmutableMappable {
    let predictions: [PlaceAutocompleteResponseItem]

    init(map: Map) throws {
        predictions = try map.value("predictions")
    }

    mutating func mapping(map: Map) {
        predictions >>> map["predictions"]
    }
}
