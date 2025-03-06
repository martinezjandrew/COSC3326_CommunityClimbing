//
//  Holds.swift
//  communityclimbing
//
//  Created by Turing on 11/28/23.
//

import Foundation
import UIKit

struct Hold {
    var name: String
    var imageName: String
    
    init(name: String, imageName:String){
        self.name = name
        self.imageName = imageName
    }
}

var holdsList: [Hold] = [
    Hold(name: "Crack", imageName: "hold_crack"), Hold(name: "Crimp", imageName: "hold_crimp"), Hold(name: "Edge", imageName: "hold_edge"), Hold(name: "Flake", imageName: "hold_flake"), Hold(name: "Horn", imageName: "hold_horn"), Hold(name: "Jug", imageName: "hold_jug"), Hold(name: "Pinch", imageName: "hold_pinch"), Hold(name: "Pocket", imageName: "hold_pocket"), Hold(name: "Sloper", imageName: "hold_sloper"), Hold(name: "Undercling", imageName: "hold_undercling"), Hold(name: "Volume", imageName: "hold_volume")
]
