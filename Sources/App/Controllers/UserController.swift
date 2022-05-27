//
//  File.swift
//  
//
//  Created by Artemiy Zuzin on 15.05.2022.
//

import Foundation
import Fluent
import Vapor

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        let passwordProtected = routes.grouped(User.authenticator())
                
        users.get(use: self.index(req:))
        users.post("new", use: self.create(req:))
        users.delete(":userID", use: self.delete(req:))
        users.get(":userID", "places", use: self.getUserPlaces(req:))
        
        passwordProtected.get("user", "auth", use: self.getAuth(req:))
    }
    
    func index(req: Request) async throws -> [User] {
        try await User.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> User {
        try User.Create.validate(content: req)
        
        let create = try req.content.decode(User.Create.self)
        let user = try User(email: create.email, passwordHash: Bcrypt.hash(create.password))
        
        try await user.save(on: req.db)
                
        return user
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else { throw Abort(.notFound) }
        
        try await user.delete(on: req.db)
        
        return .ok
    }
    
    func getAuth(req: Request) async throws -> User {
        try req.auth.require(User.self)
    }
    
    func getUserPlaces(req: Request) async throws -> [CreatePlaceData] {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else { throw Abort(.notFound) }

        let places = try await user.$places.get(on: req.db)
        var newPlaces = [CreatePlaceData]()

        places.forEach { newPlaces.append(CreatePlaceData(id: $0.id, name: $0.name, street: $0.street, placeDescription: $0.placeDescription, lat: $0.lat, lon: $0.lon, image: $0.image, userID: $0.$user.id )) }
        
        return newPlaces
    }
    
}
