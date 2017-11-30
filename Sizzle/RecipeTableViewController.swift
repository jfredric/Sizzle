//
//  RecipeTableViewController.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 11/27/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import UIKit

class RecipeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, VoiceRecognitionDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var speechRecognizerLabel: UILabel!
    
    var currentRecipe: Recipe!
    var voiceController = VoiceController()
    
    // MARK: ACTION FUNCTIONS
    
    @IBAction func startTapped(_ sender: UIBarButtonItem) {
        // begin voice recognition
        voiceController.startRecordingSpeech()
    }
    
    // MARK: VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        voiceController.voiceHandler = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: VOICE CONTROLLER DELEGATE
    func speechRecognized(text: String) {
        if text.lowercased().contains("next") {
            speechRecognizerLabel.text = "NEXT"
            voiceController.restartRecordingSpeech()
        } else {
            speechRecognizerLabel.text = text
        }
    }

    // MARK: TABLE VIEW

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentRecipe.totalSteps
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = (tableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell-ID", for: indexPath) as? HomeTableViewCell) else {
            fatalError("Error [Recipe]: Could not cast cell as HomeTableViewCell")
        }
        
        // Configure the cell...
        cell.titleLabel.text = currentRecipe.steps[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let speechText = currentRecipe.steps[indexPath.row]
        voiceController.speak(text: speechText)

    }

}
