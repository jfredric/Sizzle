//
//  Recipe.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 11/26/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import Foundation

protocol RecipeProgressViewDelegate {
    func recipeStart()
    func recipeFinished()
    func moveTo(step: Int)
}

protocol RecipeDictateDelegate {
    func dictate(stepText: String)
    func dictateFinished()
    //func dictateStart()
}

class Recipe: VoiceCommandsDelegate {
    
    
    // MARK: PROPERTIES
    var title: String
    private var _currentStep: Int?
    public var   currentStep: Int? { return _currentStep}
    private var steps: [String]
    public var stepCount: Int { return steps.count }
    
    var progressViewDelegate: RecipeProgressViewDelegate?
    var dictateDelegate: RecipeDictateDelegate?
    
    init(title: String, steps: [String]) {
        self.title = title
        self.steps = steps
    }
    
    func stepText(forSpeechAt index: Int) -> String {
        print("Warning [Recipe]: the stepText(forSpeechAt) function is depricated")
        return steps[index]
    }
    
    func stepText(forViewAt index: Int) -> String {
        return steps[index]
    }
    
    func jumpTo(step index: Int, sender: Any) {
        if index >= steps.count {
            return
        }
        
        _currentStep = index
        
        if !(sender is RecipeProgressViewDelegate) {
            progressViewDelegate?.moveTo(step: index)
        }
        
        if !(send is RecipeDictateDelegate) {
            dictateDelegate?.dictate(stepText: steps[index])
        }
    }
    
    // Returns nil if no more steps exist
    func next() {
        if steps.count == 0 { // no steps in this recipe.
                progressViewDelegate?.recipeFinished()
        } else if let current = _currentStep {
            if current + 1 == steps.count { // end of steps
                _currentStep = nil
                dictateDelegate?.dictateFinished()
                progressViewDelegate?.recipeFinished()
            } else { // going on to next step.
                _currentStep = current + 1
                dictateDelegate?.dictate(stepText: steps[_currentStep!])
                progressViewDelegate?.moveTo(step: _currentStep!)
            }
        } else { // have not started yet, going to first step
            _currentStep = 0
            dictateDelegate?.dictate(stepText: steps[_currentStep!])
            progressViewDelegate?.moveTo(step: _currentStep!)
        }
        
    }
    
    // MARK: VOICE COMMANDS DELEGATE
    func executeNextCommand() {
        next()
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
