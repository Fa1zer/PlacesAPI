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
        
        users.get(use: self.index(req:))
        users.post(use: self.create(req:))
        users.group(":userID") { user in
            user.get("places", use: self.getPlaces(req:))
            user.delete(use: self.delete(req:))
        }
    }
    
    func index(req: Request) async throws -> [User] {
        try await User.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> User {
        let user = try req.content.decode(User.self)
        
        try await user.save(on: req.db)
        
        return user
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else { throw Abort(.notFound) }
        
        try await user.delete(on: req.db)
        
        return .ok
    }
    
    func getPlaces(req: Request) async throws -> [Place] {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else { throw Abort(.notFound) }
        
        return try await user.$places.get(on: req.db)
    }
    
}
