//
//  RecipeTableViewController.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 11/27/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import UIKit

class RecipeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, VoiceStatusDisplayDelegate, RecipeProgressViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var speechRecognizerLabel: UILabel!
    
    var currentRecipe: Recipe!
    var voiceController = VoiceController()
    
    
    // MARK: ACTION FUNCTIONS
    
    @IBAction func startTapped(_ sender: UIBarButtonItem) {
        // begin voice recognition
        voiceController.startRecordingSpeech()
        // dissable button
    }
    
    // MARK: VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set various delegates
        tableView.delegate = self
        tableView.dataSource = self
        voiceController.displayDelegate = self
        voiceController.commandDelegate = currentRecipe
        currentRecipe.dictateDelegate = voiceController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: RECIPE DELEGATE
    func recipeStart() {
        // disable button
    }
    
    func recipeFinished() {
        // display alert???
        // enable start button
    }
    
    func moveTo(step: Int) {
        let indexPath = IndexPath(row: step, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.top)
    }
    
    // MARK: VOICE CONTROLLER DELEGATE
    func speechRecognized(text: String) {
        speechRecognizerLabel.text = text
    }

    // MARK: TABLE VIEW DELEGATE

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentRecipe.stepCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = (tableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell-ID", for: indexPath) as? HomeTableViewCell) else {
            fatalError("Error [Recipe]: Could not cast cell as HomeTableViewCell")
        }
        
        // Configure the cell...
        cell.titleLabel.text = currentRecipe.stepText(forViewAt: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentRecipe.jumpTo(step: indexPath.row, sender: self)
    }

}
