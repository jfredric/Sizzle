//
//  UnitOfMeasure.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 12/4/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import Foundation

class UnitOfMeasure {
    let abbr: String
    let spoken_singular: String
    let spoken_plural: String
    
    static let tbsp = UnitOfMeasure(abbr: "tbsp", spoken_singular: "tablespoon", spoken_plural: "tablespoons")
    static let tsp = UnitOfMeasure(abbr: "tsp", spoken_singular: "teaspoon", spoken_plural: "teaspoons")
    static let oz = UnitOfMeasure(abbr: "oz", spoken_singular: "ounce", spoken_plural: "ounces")
    static let lb = UnitOfMeasure(abbr: "lb", spoken_singular: "pound", spoken_plural: "pounds")
    static let g = UnitOfMeasure(abbr: "g", spoken_singular: "gram", spoken_plural: "grams")
    static let cup = UnitOfMeasure(abbr: "cup", spoken_singular: "cup", spoken_plural: "cups")
    static let ml = UnitOfMeasure(abbr: "ml", spoken_singular: "milliliter", spoken_plural: "milliliters")
    static let l = UnitOfMeasure(abbr: "l", spoken_singular: "liter", spoken_plural: "liters")
    static let none = UnitOfMeasure(abbr: "", spoken_singular: "", spoken_plural: "")
    
    private init(abbr: String, spoken_singular: String, spoken_plural: String) {
        self.abbr = abbr
        self.spoken_singular = spoken_singular
        self.spoken_plural = spoken_plural
    }
}
