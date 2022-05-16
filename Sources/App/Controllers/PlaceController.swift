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
        places.post(use: self.create(req:))
        places.put(use: self.change(req:))
        places.group(":placeID") { place in
            place.delete(use: self.delete(req:))
            place.get(use: self.getPlace(req:))
            place.get("user", use: self.getUser(req:))
        }
    }
    
    func index(req: Request) async throws -> [Place] {
        return try await Place.query(on: req.db).all()
    }
    
    func getPlace(req: Request) async throws -> Place {
        guard let place = try await Place.find(req.parameters.get("placeID"), on: req.db) else { throw Abort(.notFound) }
        
        return place
    }
    
    func create(req: Request) async throws -> Place {
        let createPlace = try req.content.decode(CreatePlaceData.self)
        let place = Place(
            name: createPlace.name,
            street: createPlace.street,
            placeDescription: createPlace.placeDescription,
            userID: createPlace.userID
        )
        
        try await place.save(on: req.db)
        
        return place
    }
    
    func change(req: Request) async throws -> Place {
        let newPlace = try req.content.decode(Place.self)
        let oldPlace = try await Place.find(newPlace.id, on: req.db)
        
        oldPlace?.name = newPlace.name
        oldPlace?.street = newPlace.street
        oldPlace?.placeDescription = newPlace.placeDescription
        
        try await oldPlace?.save(on: req.db)
        
        return newPlace
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
    
    struct CreatePlaceData: Content {
        let name: String
        let street: String
        let placeDescription: String
        let userID: UUID
    }
    
}
