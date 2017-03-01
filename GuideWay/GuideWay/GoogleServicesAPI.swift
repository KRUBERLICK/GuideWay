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
    static let apiKey = "AIzaSyCcovS3o38O9B888ic5iRs9nhx4k83oVMc"
    static let placeAutocompleteURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    static let directionsURL = "https://maps.googleapis.com/maps/api/directions/json"
    let webService: WebService

    init(webService: WebService) {
        self.webService = webService
    }

    func requestPlaceAutocomplete(for input: String) -> Observable<PlaceAutocompleteResponse> {
        return Observable.create { observer in
            self.webService.resource(absoluteURL: GoogleServicesAPI.placeAutocompleteURL)
                .withParam("key", GoogleServicesAPI.apiKey)
                .withParam("input", input)
                .withParam("language", Locale.current.languageCode ?? "en")
                .withParam("location", "50.448731,30.463405")
                .withParam("radius", "10000")
                .withParam("types", "address")
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

    func requestDirections(from origin: String, to destination: String) -> Observable<DirectionsResponse> {
        return Observable.create { observer in
            self.webService.resource(absoluteURL: GoogleServicesAPI.directionsURL)
                .withParam("key", GoogleServicesAPI.apiKey)
                .withParam("language", Locale.current.languageCode ?? "en")
                .withParam("origin", origin)
                .withParam("destination", destination)
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
