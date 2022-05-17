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
    
    @Field(key: "lat")
    var lat: Float
    
    @Field(key: "lon")
    var lon: Float
    
    @Parent(key: "user_id")
    var user: User
    
    init() { }
    
    init(id: UUID? = nil, name: String, street: String, placeDescription: String, lat: Float, lon: Float, userID: User.IDValue) {
        self.id = id
        self.name = name
        self.street = street
        self.placeDescription = placeDescription
        self.lat = lat
        self.lon = lon
        self.$user.id = userID
    }
    
}
