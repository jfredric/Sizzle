//
//  Ingredient.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 12/4/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import Foundation

class Ingredient {
    let name: String
    let namePlural: String
    var quantity: Double?
    var units: UnitOfMeasure
    
    // MARK: CONSTANTS
    struct SwiftFractions {
         static let OneThird: Double = 1.0 / 3.0
         static let TwoThirds: Double = 1.0 / 3.0
         static let OneEigth: Double = 1.0 / 8.0
         static let ThreeEigths: Double = 3.0 / 8.0
         static let FiveEigths: Double = 5.0 / 8.0
         static let SevenEigths: Double = 7.0 / 8.0
    }
    
    struct UnicodeFractions {
         static let OneHalf = "\u{00BD}"
         static let OneQuarter = "\u{00BC}"
         static let ThreeQuarter = "\u{00BE}"
         static let OneThird = "\u{2153}"
         static let TwoThirds = "\u{2154}"
         static let OneEigth = "\u{215B}"
         static let ThreeEigths = "\u{215C}"
         static let FiveEigths = "\u{215E}"
         static let SevenEigths = "\u{215D}"
    }
    
    init(name: String, namePlural: String, quantity: Double?, units: UnitOfMeasure) {
        self.name = name
        self.namePlural = namePlural
        self.quantity = quantity
        self.units = units
    }
    
    func toStringReadable() -> String {
        var readable = ""
        
        if let qty = quantity {
            let whole = floor(qty)
            let fraction = qty - whole
            
            switch fraction {
            case 0.5 :
                readable += (qty >= 1 ? String(format: "%g", floor(qty)) : "") + UnicodeFractions.OneHalf
            case 0.25 :
                readable += (qty >= 1 ? String(format: "%g", floor(qty)) : "") + UnicodeFractions.OneQuarter
            case 0.75 :
                readable += (qty >= 1 ? String(format: "%g", floor(qty)) : "") + UnicodeFractions.ThreeQuarter
            case SwiftFractions.OneThird :
                readable += (qty >= 1 ? String(format: "%g", floor(qty)) : "") + UnicodeFractions.OneThird
            case SwiftFractions.TwoThirds :
                readable += (qty >= 1 ? String(format: "%g", floor(qty)) : "") + UnicodeFractions.TwoThirds
            case SwiftFractions.OneEigth :
                readable += (qty >= 1 ? String(format: "%g", floor(qty)) : "") + UnicodeFractions.OneEigth
            case SwiftFractions.ThreeEigths :
                readable += (qty >= 1 ? String(format: "%g", floor(qty)) : "") + UnicodeFractions.ThreeEigths
            case SwiftFractions.FiveEigths :
                readable += (qty >= 1 ? String(format: "%g", floor(qty)) : "") + UnicodeFractions.FiveEigths
            case SwiftFractions.SevenEigths :
                readable += (qty >= 1 ? String(format: "%g", floor(qty)) : "") + UnicodeFractions.SevenEigths
            default :
                readable += String(format: "%g", qty)
            }
            if units !== UnitOfMeasure.none {
                readable +=  " " + units.abbr
            }
            readable += " " + (qty <= 1.0 ? name : namePlural)
        } else {
            readable += name
        }
        
        return readable
    }
    
    func toStringSpoken() -> String {
        var spoken = ""
        if let qty = quantity {
            let whole = floor(qty)
            let fraction = qty - whole
            
            switch fraction {
            case 0.5 :
                spoken += (qty >= 1 ? String(format: "%g", floor(qty)) + " and " : "") + "one half"
            case 0.25 :
                spoken += (qty >= 1 ? String(format: "%g", floor(qty)) + " and " : "") + "one quarter"
            case 0.75 :
                spoken += (qty >= 1 ? String(format: "%g", floor(qty)) + " and " : "") + "3 quarters"
            case SwiftFractions.OneThird :
                spoken += (qty >= 1 ? String(format: "%g", floor(qty)) + " and " : "") + "one third"
            case SwiftFractions.TwoThirds :
                spoken += (qty >= 1 ? String(format: "%g", floor(qty)) + " and " : "") + "two thirds"
            case SwiftFractions.OneEigth :
                spoken += (qty >= 1 ? String(format: "%g", floor(qty)) + " and " : "") + "one eigth"
            case SwiftFractions.ThreeEigths :
                spoken += (qty >= 1 ? String(format: "%g", floor(qty)) + " and " : "") + "three eigths"
            case SwiftFractions.FiveEigths :
                spoken += (qty >= 1 ? String(format: "%g", floor(qty)) + " and " : "") + "five eigths"
            case SwiftFractions.SevenEigths :
                spoken += (qty >= 1 ? String(format: "%g", floor(qty)) + " and " : "") + "seven eigths"
            default :
                spoken += String(format: "%g", qty)
            }
            if units !== UnitOfMeasure.none {
                spoken += " " + (qty <= 1.0 ? units.spoken_singular : units.spoken_plural) + " of"
            }
            spoken += " " + (qty <= 1.0 ? name : namePlural)
        } else {
            spoken += name
        }
        
        return spoken
    }
}
