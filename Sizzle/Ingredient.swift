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
    
    init(name: String, namePlural: String, quantity: Double?, units: UnitOfMeasure) {
        self.name = name
        self.namePlural = namePlural
        self.quantity = quantity
        self.units = units
    }
    
    func toStringReadable() -> String {
        var readable = ""
        
        if let qty = quantity {
            readable += String(qty)
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
        var readable = ""
        if let qty = quantity {
            readable += String(qty)
            if units !== UnitOfMeasure.none {
                readable += " " + (qty <= 1.0 ? units.spoken_singular : units.spoken_plural)
            }
            readable += " " + (qty <= 1.0 ? name : namePlural)
        } else {
            readable += name
        }
        
        return readable
    }
}
