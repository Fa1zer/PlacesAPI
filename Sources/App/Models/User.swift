//
//  File.swift
//  
//
//  Created by Artemiy Zuzin on 15.05.2022.
//

import Foundation
import Fluent
import Vapor

final class User: Model, Content {
    
    static let schema = "users"
    
    @ID(custom: "user_id", generatedBy: .user)
    var id: UUID?
    
    @Children(for: \.$user)
    var places: [Place]
    
    init() { }
    
    init(id: UUID? = nil) {
        self.id = id
    }
    
}
