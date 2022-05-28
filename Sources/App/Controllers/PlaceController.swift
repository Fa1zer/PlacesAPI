//
//  File.swift
//  
//
//  Created by Artemiy Zuzin on 10.05.2022.
//

import Foundation
import Fluent
import Vapor

struct PlaceController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let places = routes.grouped("places")
                
        places.get(use: self.index(req:))
        places.post("new", use: self.create(req:))
        places.put("redact", use: self.change(req:))
        places.group(":placeID") { place in
            place.delete(use: self.delete(req:))
            place.get(use: self.getPlace(req:))
            place.get("user", use: self.getUser(req:))
        }
    }
    
    func index(req: Request) async throws -> [CreatePlaceData] {
        let places = try await Place.query(on: req.db).all()
        var newPlaces = [CreatePlaceData]()
        
        places.forEach { newPlaces.append(CreatePlaceData(id: $0.id, name: $0.name, street: $0.street, placeDescription: $0.placeDescription, lat: $0.lat, lon: $0.lon, image: $0.image, userID: $0.$user.id )) }
        
        return newPlaces
    }
    
    func getPlace(req: Request) async throws -> CreatePlaceData {
        guard let place = try await Place.find(req.parameters.get("placeID"), on: req.db) else { throw Abort(.notFound) }
        
        return CreatePlaceData(id: place.id, name: place.name, street: place.street, placeDescription: place.placeDescription, lat: place.lat, lon: place.lon, image: place.image, userID: place.$user.id )
    }
    
    func create(req: Request) async throws -> Place {
        let createPlace = try req.content.decode(CreatePlaceData.self)
        let place = Place(
            name: createPlace.name,
            street: createPlace.street,
            placeDescription: createPlace.placeDescription,
            lat: createPlace.lat,
            lon: createPlace.lon,
            image: createPlace.image,
            userID: createPlace.userID
        )
        
        try await place.save(on: req.db)
        
        return place
    }
    
    func change(req: Request) async throws -> Place {
        let newPlace = try req.content.decode(CreatePlaceData.self)
        let oldPlace = try await Place.find(newPlace.id, on: req.db)
        
        oldPlace?.name = newPlace.name
        oldPlace?.street = newPlace.street
        oldPlace?.placeDescription = newPlace.placeDescription
        oldPlace?.lat = newPlace.lat
        oldPlace?.lon = newPlace.lon
        oldPlace?.image = newPlace.image
        
        let place = Place(name: newPlace.name, street: newPlace.street, placeDescription: newPlace.placeDescription, lat: newPlace.lat, lon: newPlace.lon, userID: newPlace.userID)
        
        try await oldPlace?.save(on: req.db)
        
        return place
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let place = try await Place.find(req.parameters.get("placeID"), on: req.db) else { throw Abort(.notFound) }
        
        try await place.delete(on: req.db)
        
        return .ok
    }
    
    func getUser(req: Request) async throws -> User {
        guard let place = try await Place.find(req.parameters.get("placeID"), on: req.db) else { throw Abort(.notFound) }
        
        return try await place.$user.get(on: req.db)
    }
    
}

struct CreatePlaceData: Content {
    
    let id: UUID?
    let name: String
    let street: String
    let placeDescription: String
    let lat: Float
    let lon: Float
    let image: String?
    let userID: UUID
    
    init(id: UUID? = nil, name: String, street: String, placeDescription: String, lat: Float, lon: Float, image: String? = nil, userID: UUID) {
        self.id = id
        self.name = name
        self.street = street
        self.placeDescription = placeDescription
        self.lat = lat
        self.lon = lon
        self.image = image
        self.userID = userID
    }
    
}
