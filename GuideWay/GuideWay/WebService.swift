//
//  WebService.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/23/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import Siesta
import ObjectMapper

class WebService: Service {
    init() {
        super.init(baseURL: nil, useDefaultTransformers: true)
        setupTransformers()
    }

    func setupTransformers() {
        configureTransformer(GoogleServicesAPI.placeAutocompleteURL)
        {
            (data: Entity<[String: Any]>) throws -> PlaceAutocompleteResponse in
            try Mapper<PlaceAutocompleteResponse>().map(JSON: data.content)
        }
        configureTransformer(GoogleServicesAPI.directionsURL)
        {
            (data: Entity<[String: Any]>) throws -> DirectionsResponse in
            try Mapper<DirectionsResponse>().map(JSON: data.content)
        }
    }
}
