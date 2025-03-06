//
//  Gym.swift
//  communityclimbing
//
//  Created by Turing on 12/3/23.
//

import Foundation

struct Gym {
    let name: String
    let streetAddress: String
    let city: String
    let state: String
    let latitude: Double
    let longitude: Double
    
    init(name: String, streetAddress: String, city: String, state: String, latitude: Double, longitude: Double) {
        self.name = name
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.latitude = latitude
        self.longitude = longitude
    }
}

//var gyms: [String] = ["Austin Bouldering Project","Crux Climbing","Mesa Project", "Armadillo Bouldering"]

var gyms: [Gym] = [
    Gym(name: "Austin Boulering Project - Springdale", streetAddress: "979 Springdale Rd #150", city: "Austin", state: "Texas", latitude: 30.263213357950928, longitude: -97.69625771640453),
    Gym(name: "Crux Climbing Center", streetAddress: "121 Pickle Rd #100", city: "Austin", state: "Texas", latitude: 30.22769872631626, longitude: -97.76298546126499),
    Gym(name: "Mesa Rim Climbing Center", streetAddress: "1205 Sheldon Cove Building 3", city: "Austin", state: "Texas", latitude: 30.343538586386998, longitude: -97.68555776496557)
]
