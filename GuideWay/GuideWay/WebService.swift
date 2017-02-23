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
        configureTransformer(GoogleServicesAPI.placeSearchURL)
        {
            (data: Entity<[String: Any]>) throws -> PlaceSearchResponse in
            try Mapper<PlaceSearchResponse>().map(JSON: data.content)
        }
    }
}