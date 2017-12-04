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
                dictateDelegate?.dictate(stepText: "You are done, enjoy!")
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
    
    func prev() {
        if steps.count == 0 { // no steps in this recipe.
            progressViewDelegate?.recipeFinished()
        } else if let current = _currentStep {
            if current - 1 < 0 { // already at the first step
                _currentStep = 0
                dictateDelegate?.dictate(stepText: "You're on the first step. Did you want me to repeat it?")
            } else { // going on to previous step.
                _currentStep = current - 1
                dictateDelegate?.dictate(stepText: steps[_currentStep!])
                progressViewDelegate?.moveTo(step: _currentStep!)
            }
        } else { // have not started yet, going to first step
            _currentStep = 0
            dictateDelegate?.dictate(stepText: steps[_currentStep!])
            progressViewDelegate?.moveTo(step: _currentStep!)
        }
    }
    
    func stop() {
        _currentStep = nil
        dictateDelegate?.dictate(stepText: "Stopping cooking activity.")
    }
    
    // MARK: VOICE COMMANDS DELEGATE
    func executeNextCommand() {
        next()
    }
    
    func executePrevCommand() {
        prev()
    }
    
    func executeStopCommand() {
        stop()
        progressViewDelegate?.recipeFinished()
    }
    
    func executeRepeatCommand() {
        if _currentStep != nil {
            dictateDelegate?.dictate(stepText: steps[_currentStep!])
        } else {
            print("Error [Recipe]: The recipe has not started yet. Cannot repeat")
        }
    }
    
    // test data
    static func testEggs() -> Recipe {
    
        let testSteps = [
            "Add 1 teaspoon of oil to pan",
            "Set heat to medium and wait for the pan to come to temperature",
            "Crack egg, and drop gently into pan",
            "Salt and pepper lightly",
            "wait 1.5 minutes",
            "Using spatula, flip the egg",
            "wait an additional 1.5 minutes",
            "Remove fried egg to plate"]
    
        return Recipe(title: "Fried Eggs", steps: testSteps)
    }
    
    static func short() -> Recipe {
        let testSteps = [
            "Do step 1",
            "Do step 2",
            "Do step 3"]
        return Recipe(title: "Short Test", steps: testSteps)
    }
    
    static func long() -> Recipe {
        let testSteps = [
            "Do step 1",
            "Do step 2",
            "Do step 3",
            "Do step 4",
            "Do step 5",
            "Do step 6",
            "Do step 7",
            "Do step 8",
            "Do step 9",
            "Do step 10",
            "Do step 11",
            "Do step 12",
            "Do step 13",
            "Do step 14",
            "Do step 15"]
        
        return Recipe(title: "Long Test", steps: testSteps)
    }
}
