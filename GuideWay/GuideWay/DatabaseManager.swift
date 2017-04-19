//
//  DatabaseManager.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 4/19/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import Firebase
import RxSwift

class DatabaseManager {
    let database: FIRDatabase

    var ref: FIRDatabaseReference {
        get {
            return database.reference()
        }
    }

    var usersNode: FIRDatabaseReference {
        get {
            return ref.child("users")
        }
    }

    var routesNode: FIRDatabaseReference {
        get {
            return ref.child("routes")
        }
    }

    init(database: FIRDatabase) {
        self.database = database
    }

    func addUser(uid: String,
                 email: String) -> Observable<Bool> {
        return Observable.create { observer in
            self.usersNode.child(uid).updateChildValues(
                ["email": email],
                withCompletionBlock: { error, ref in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    observer.onNext(true)
                    observer.onCompleted()
            })
            return Disposables.create()
        }
    }

    func addRoute(_ route: Route, ownerId: String) -> Observable<Route> {
        return Observable.create { observer in
            let newRouteNode = self.routesNode.childByAutoId()

            newRouteNode.updateChildValues(
                route.toJSON(),
                withCompletionBlock: { error, ref in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    var newRoute = route

                    newRoute.id = newRouteNode.key
                    self.usersNode.child(ownerId)
                        .updateChildValues(
                            [newRouteNode.key: 0],
                            withCompletionBlock: { error, ref in
                                if let error = error {
                                    observer.onError(error)
                                    return
                                }

                                observer.onNext(newRoute)
                                observer.onCompleted()
                        })
            })
            return Disposables.create()
        }
    }

    func updateRoute(_ route: Route) -> Observable<Bool> {
        return Observable.create { observer in
            self.routesNode.child(route.id!)
                .updateChildValues(
                    route.toJSON(),
                    withCompletionBlock: { error, ref in
                        if let error = error {
                            observer.onError(error)
                            return
                        }

                        observer.onNext(true)
                        observer.onCompleted()
                })
            return Disposables.create()
        }
    }

    func deleteRoute(with routeId: String, ownerId: String) -> Observable<Bool> {
        return Observable.create { observer in
            self.routesNode.child(routeId)
                .removeValue(completionBlock: { error, ref in
                    if let error = error {
                        observer.onError(error)
                        return
                    }

                    self.usersNode.child(ownerId).child(routeId)
                        .removeValue(completionBlock: { error, ref in
                            if let error = error {
                                observer.onError(error)
                                return
                            }

                            observer.onNext(true)
                            observer.onCompleted()
                        })
            })
            return Disposables.create()
        }
    }

    func getRoutesList(forUserId userId: String) -> Observable<Route> {
        return Observable.create { observer in
            self.usersNode.child(userId).observe(.childAdded, with: { snapshot in
                self.routesNode.child(snapshot.key)
                    .observeSingleEvent(
                        of: .value, 
                        with: { snapshot in
                            guard var dict = snapshot.value as? [String: Any] else {
                                observer.onError(NSError())
                                return
                            }

                            dict["id"] = snapshot.key
                            if let route = try? Route(JSON: dict) {
                                observer.onNext(route)
                            }

                }, withCancel: { error in
                    observer.onError(error)
                })
            }, withCancel: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }
}
