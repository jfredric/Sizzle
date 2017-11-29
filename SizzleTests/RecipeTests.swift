//
//  RecipeTests.swift
//  SizzleTests
//
//  Created by Joshua Fredrickson on 11/26/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import XCTest
@testable import Sizzle

class RecipeTests: XCTestCase {
    
    var recipeUnderTest: Recipe!
    let testSteps = [
        "Add 1 teaspoon of oil to pan",
        "Set heat to medium and wait for the pan to come to temperature",
        "Crack egg, and drop gentlying into pan",
        "Salt and pepper lightly",
        "wait 1 1/2 minutes",
        "Using spatula, flip the egg",
        "wait an additional 1 1/2 minutes",
        "Remove fried egg to plate"]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        recipeUnderTest = Recipe(title: "Fried Eggs", steps: testSteps)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNext() {
        // test that next funciton returns the correct values
        for testStep in testSteps {
            let nextStep = recipeUnderTest.next()
            XCTAssertEqual(nextStep ?? "nil", testStep)
        }
        
        // test that last step returns nil
        XCTAssertNil(recipeUnderTest.next())
        
        // test empty list returns nil
        let emptyRecipe = Recipe(title: "Nothing", steps: [])
        XCTAssertNil(emptyRecipe.next())
        
    }
    
}
