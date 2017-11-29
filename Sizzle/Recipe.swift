//
//  Recipe.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 11/26/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import Foundation

class Recipe {
    public var title: String
    public var totalSteps: Int {
        return steps.count
    }
    private var currentStep: Int?
    public var steps: [String]
    
    init(title: String, steps: [String]) {
        self.title = title
        self.steps = steps
    }
    
    // Returns nil if no more steps exist
    func next() -> String? {
        //empty list returns nil
        if steps.count == 0 {
            return nil
        }
        
        if let current = currentStep {
            // end of steps, returns nil
            if current == steps.count {
                return nil
            }
            currentStep = current + 1
            return steps[current]
        } else {
            currentStep = 1
            return steps[0]
        }
        
    }
    
    
    // test data
    static func testEggs() -> Recipe {
    
        let testSteps = [
            "Add 1 teaspoon of oil to pan",
            "Set heat to medium and wait for the pan to come to temperature",
            "Crack egg, and drop gentlying into pan",
            "Salt and pepper lightly",
            "wait 1 1/2 minutes",
            "Using spatula, flip the egg",
            "wait an additional 1 1/2 minutes",
            "Remove fried egg to plate"]
    
        return Recipe(title: "Fried Eggs", steps: testSteps)
    }
}
