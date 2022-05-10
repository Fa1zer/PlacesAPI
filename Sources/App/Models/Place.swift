//
//  File.swift
//  
//
//  Created by Artemiy Zuzin on 10.05.2022.
//

import Foundation
import Fluent
import Vapor

final class Place: Model, Content {
    
    static let schema = "places"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "street")
    var street: String
    
    @Field(key: "place_description")
    var placeDescription: String
    
    init() { }
    
    init(id: UUID? = nil, name: String, street: String, placeDescription: String) {
        self.id = id
        self.name = name
        self.street = street
        self.placeDescription = placeDescription
    }
    
}
