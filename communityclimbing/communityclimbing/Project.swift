//
//  Project.swift
//  communityclimbing
//
//  Created by Turing on 12/3/23.
//

import Foundation

class Project{
    let name: String
    let creator: String
    let availableSnapPoints: String
    let occupiedSnapPoints: String
    let snapPoints: String
    let gym: String
    let wallWidth: Int
    let wallHeight: Int
    
    init(name: String, creator: String, availableSnapPoints: String, occupiedSnapPoints: String, gym: String, snapPoints: String, wallWidth: Int, wallHeight:Int) {
        self.name = name
        self.creator = creator
        self.availableSnapPoints = availableSnapPoints
        self.occupiedSnapPoints = occupiedSnapPoints
        self.gym = gym
        self.snapPoints = snapPoints
        self.wallWidth = wallWidth
        self.wallHeight = wallHeight
    }
}
