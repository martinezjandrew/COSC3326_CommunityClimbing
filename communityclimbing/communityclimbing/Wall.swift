//
//  Wall.swift
//  communityclimbing
//
//  Created by Turing on 12/3/23.
//

import Foundation

struct Wall {
    var name: Int
    var gym: String
    var width: Int
    var height: Int
    
    init(name: Int, gym: String, width: Int, height: Int) {
        self.name = name
        self.gym = gym
        self.width = width
        self.height = height
    }
}
