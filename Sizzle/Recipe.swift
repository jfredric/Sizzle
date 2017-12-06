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
    public var stepCount: Int { return steps.count}
    private var ingredients: [Ingredient]
    
    
    var progressViewDelegate: RecipeProgressViewDelegate?
    var dictateDelegate: RecipeDictateDelegate?
    
    init(title: String, ingredients: [Ingredient], steps: [String]) {
        self.title = title
        self.ingredients = ingredients
        self.steps = steps
    }
    
//    func stepText(forSpeechAt index: Int) -> String {
//        print("Warning [Recipe]: the stepText(forSpeechAt) function is depricated")
//        return steps[index - 1]
//    }
    
    func stepText(forViewAt index: Int) -> String {
        return steps[index]
    }
    
    func ingredientsListAsTextBlock() -> String {
        var textBlock = ""
        for (index, ingredient) in ingredients.enumerated() {
            textBlock += ingredient.toStringReadable()
            if index != ingredients.count - 1 {
                textBlock += "\n"
            }
        }
        return textBlock
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
            // dictateDelegate?.dictateFinished() // this might be needed
        } else if let current = _currentStep {
            if current == steps.count - 1 {
                _currentStep = nil
                dictateDelegate?.dictate(stepText: "Your meal is ready to serve and enjoy!")
                dictateDelegate?.dictateFinished()
                progressViewDelegate?.recipeFinished()
            } else { // going on to next step.
                _currentStep = current + 1
                dictateDelegate?.dictate(stepText: steps[_currentStep!])
                progressViewDelegate?.moveTo(step: _currentStep!)
            }
        } else { // have not started yet, going to first step
            _currentStep = 0
            dictateDelegate?.dictate(stepText: steps[0])
            progressViewDelegate?.moveTo(step: 0)
        }
        
    }
    
    func prev() {
        if steps.count == 0 { // no steps in this recipe.
            progressViewDelegate?.recipeFinished()
            // dictateDelegate?.dictateFinished() // this might be needed
        } else if let current = _currentStep {
            if _currentStep == nil { // ingredients step
                
            } else if _currentStep == 0 { // already at the first step
                dictateDelegate?.dictate(stepText: "You are currently on the first step. If you would like to hear it again you can say...repeat step...")
            } else {
                _currentStep = current - 1
                dictateDelegate?.dictate(stepText: steps[_currentStep!])
                progressViewDelegate?.moveTo(step: _currentStep!)
            }
        } else { // have not started yet, going to first step
            dictateDelegate?.dictate(stepText: "If you are ready to start cooking then you can say...start cooking.")
            //_currentStep = 0
            //progressViewDelegate?.moveTo(step: _currentStep!)
        }
    }
    
    func start() {
        if let current = _currentStep {
            dictateDelegate?.dictate(stepText: "We are already cooking. If you meant to stop cooking then please try again.")
        } else {
            _currentStep = 0
            dictateDelegate?.dictate(stepText: steps[0])
            progressViewDelegate?.moveTo(step: 0)
        }
    }
    
    func stop() {
        _currentStep = nil
        dictateDelegate?.dictate(stepText: "Stopping cooking activity.")
    }
    
    // MARK: VOICE COMMANDS DELEGATE
    func executeCommandStart() {
        start()
    }
    
    func executeCommandNext() {
        next()
    }
    
    func executeCommandPrev() {
        prev()
    }
    
    func executeCommandStop() {
        stop()
        progressViewDelegate?.recipeFinished()
    }
    
    func executeCommandRepeat() {
        if _currentStep != nil {
            dictateDelegate?.dictate(stepText: "Sure, " + steps[_currentStep!])
        } else {
            dictateDelegate?.dictate(stepText: "Sure, first gather your ingredients. When you are ready, say...start cooking.")
        }
    }
    
    func executeCommandListIngredients() {
        for ingredient in ingredients {
            dictateDelegate?.dictate(stepText: ingredient.toStringSpoken())
        }
    }
    
    // test data
    static func testEggs() -> Recipe {
        let testIngredients = [
            Ingredient(name: "egg", namePlural: "eggs", quantity: 1.0, units: UnitOfMeasure.none),
            Ingredient(name: "oil", namePlural: "oil", quantity: 1.0, units: UnitOfMeasure.tsp),
            Ingredient(name: "salt", namePlural: "salt", quantity: nil, units: UnitOfMeasure.none),
            Ingredient(name: "pepper", namePlural: "pepper", quantity: nil, units: UnitOfMeasure.none)
        ]
        
        let testSteps = [
            "Add 1 teaspon of oil to pan",
            "Set the heat to medium and wait for the pan to come to temperature",
            "Crack the egg, and drop it gently into pan",
            "Lightly salt and pepper the egg",
            "Cook for 1.5 minutes",
            "Using a spatula, flip the egg",
            "Cook for an additional 1.5 minutes",
            "Using the spatula, transfer the egg to a plate"]
    
        return Recipe(title: "Fried Eggs", ingredients: testIngredients, steps: testSteps)
    }
    
    static func short() -> Recipe {
        let testIngredients = [
            Ingredient(name: "item", namePlural: "items", quantity: 1.0, units: UnitOfMeasure.none),
            Ingredient(name: "item", namePlural: "items", quantity: 2.0, units: UnitOfMeasure.tsp)
        ]
        
        let testSteps = [
            "Do step 1",
            "Do step 2",
            "Do step 3"
        ]
        
        return Recipe(title: "Short Test", ingredients: testIngredients, steps: testSteps)
    }
    
    static func long() -> Recipe {
        let testIngredients = [
            Ingredient(name: "item", namePlural: "items", quantity: 1.0, units: UnitOfMeasure.none),
            Ingredient(name: "item", namePlural: "items", quantity: 5.0, units: UnitOfMeasure.cup),
            Ingredient(name: "item", namePlural: "items", quantity: 0.5, units: UnitOfMeasure.tbsp),
            Ingredient(name: "item", namePlural: "items", quantity: 1.5, units: UnitOfMeasure.tsp),
            Ingredient(name: "item", namePlural: "items", quantity: 3.0, units: UnitOfMeasure.lb),
            Ingredient(name: "item", namePlural: "items", quantity: 2.0, units: UnitOfMeasure.tsp)
        ]
        
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
            "Do step 15"
        ]
        
        return Recipe(title: "Long Test", ingredients: testIngredients, steps: testSteps)
    }
}
