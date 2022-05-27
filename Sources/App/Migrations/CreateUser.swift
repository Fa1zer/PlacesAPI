//
//  File.swift
//  
//
//  Created by Artemiy Zuzin on 15.05.2022.
//

import Foundation
import Fluent

struct CreateUser: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .field("user_id", .uuid, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
    
}

