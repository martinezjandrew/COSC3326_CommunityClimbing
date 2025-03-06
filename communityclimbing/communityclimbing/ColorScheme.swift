//
//  ColorScheme.swift
//  communityclimbing
//
//  Created by Turing on 12/4/23.
//

import Foundation
import UIKit

struct ColorScheme {
    let background: UIColor?
    let accentPrimary: UIColor?
    let accentSecondary: UIColor?
    let textPrimary: UIColor?
    let textSecondary: UIColor?
    let accentTertiary: UIColor?
    
    init(background: UIColor?, accentPrimary: UIColor?, accentSecondary: UIColor?, accentTertiary: UIColor?, textPrimary: UIColor?, textSecondary: UIColor?) {
        self.background = background
        self.accentPrimary = accentPrimary
        self.accentSecondary = accentSecondary
        self.accentTertiary = accentTertiary
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
    }
}
 
extension ColorScheme {
    static let shared = ColorScheme(
        background: UIColor(red: 35/255, green: 100/255, blue: 170/255, alpha: 1.0),
        accentPrimary: UIColor(red: 61/255, green: 165/255, blue: 217/255, alpha: 1.0),
        accentSecondary: UIColor(red: 115/255, green: 191/255, blue: 194/255, alpha: 1),
        accentTertiary: UIColor(red: 234/255, green: 115/255, blue: 23/255, alpha: 1),
        textPrimary: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
        textSecondary: UIColor(red: 254/255, green: 198/255, blue: 1/255, alpha: 1)
    )
}
