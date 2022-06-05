//
//  File.swift
//  
//
//  Created by Artemiy Zuzin on 10.05.2022.
//

import Foundation
import Fluent

struct CreatePlace: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema("places")
            .id()
            .field("name", .string, .required)
            .field("street", .string, .required)
            .field("place_description", .string, .required)
            .field("lat", .float, .required)
            .field("lon", .float, .required)
            .field("image", .string)
            .field("user_id", .uuid, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("places").delete()
    }
    
}
