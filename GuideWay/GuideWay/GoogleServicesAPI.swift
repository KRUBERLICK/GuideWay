//
//  GooglePlacesAPI.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/23/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import Siesta
import RxSwift

class GoogleServicesAPI {
    let apiKey = "AIzaSyCcovS3o38O9B888ic5iRs9nhx4k83oVMc"
    static let placeSearchURL = "https://maps.googleapis.com/maps/api/place/textsearch/json"
    let webService: WebService

    init(webService: WebService) {
        self.webService = webService
    }

    func requestPlaceSearch(for query: String) -> Observable<PlaceSearchResponse> {
        return Observable.create { observer in
            self.webService.resource(absoluteURL: GoogleServicesAPI.placeSearchURL)
                .withParam("key", self.apiKey)
                .withParam("query", query)
                .withParam("lang", Locale.current.languageCode ?? "en")
                .withParam("location", "50.448731,30.463405")
                .withParam("type", "street_adress")
                .request(.get)
                .onSuccess { result in
                    observer.onNext(result.typedContent()!)
                    observer.onCompleted()
                }
                .onFailure { error in
                    observer.onError(error)
                }
            return Disposables.create()
        }
    }
}
