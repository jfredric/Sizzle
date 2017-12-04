//
//  RecipeTableViewController.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 11/27/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import UIKit

class RecipeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, VoiceStatusDisplayDelegate, RecipeProgressViewDelegate {
    
    // MARK: PROPERTIES
    
    // UI Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var speechRecognizerLabel: UILabel!
    @IBOutlet weak var startButton: UIBarButtonItem!
    @IBOutlet weak var microphoneImageView: UIImageView!
    @IBOutlet weak var recognizerRingStatusView: UIView!
    
    var currentRecipe: Recipe!
    
    var voiceController = VoiceController()
    
    // MARK: CONSTANTS
    
    // Microphone Status Colors
    let microphoneActiveColor = UIColor.blue
    let microphoneIdleColor = UIColor.lightGray
    let microphoneDisabledColor = UIColor.gray
    
    // Recognizer Status Colors
    /*struct RecognizerStatusColors {
        static let active = UIColor.blue
        static let disabled = UIColor.gray
        static let paused = UIColor.lightGray
        static let success = UIColor.green
    }*/
    
    // MARK: ACTION FUNCTIONS
    
    @IBAction func startTapped(_ sender: UIBarButtonItem) {
        // begin voice recognition
        voiceController.startRecordingSpeech()
        // disable button
        startButton.isEnabled = false
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
        currentRecipe.progressViewDelegate = self
        
        microphoneImageView.tintColor = microphoneDisabledColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: RECIPE DELEGATE
    func recipeStart() {
        // disable button
        startButton.isEnabled = false
    }
    
    func recipeFinished() {
        // display alert???
        // enable start button
        startButton.isEnabled = true
        tableView.selectRow(at: nil, animated: true, scrollPosition: UITableViewScrollPosition.top)
    }
    
    func moveTo(step: Int) {
        let indexPath = IndexPath(row: step, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.top)
    }
    
    // MARK: VOICE CONTROLLER DELEGATE
    
    func speechRecognized(text: String) {
        speechRecognizerLabel.text = text
    }
    
    func microphoneUpdate(status: VoiceController.MicrophoneStatus) {
        switch status {
        case .listening:
            microphoneImageView.image = UIImage(imageLiteralResourceName: "microphone-outline")
            microphoneImageView.tintColor = microphoneActiveColor
        case .disabled:
            microphoneImageView.image = UIImage(imageLiteralResourceName: "microphone-mute-outline")
            microphoneImageView.tintColor = microphoneDisabledColor
        case .off:
            microphoneImageView.image = UIImage(imageLiteralResourceName: "microphone-outline")
            microphoneImageView.tintColor = microphoneIdleColor
        }
    }
    
    /*func recognitionUpdate(status: VoiceController.RecognitionStatus) {
        switch status {
        case .active:
            recognizerRingStatusView.backgroundColor = RecognizerStatusColors.active
        case .disabled:
            recognizerRingStatusView.backgroundColor = RecognizerStatusColors.disabled
        case .paused:
            recognizerRingStatusView.backgroundColor = RecognizerStatusColors.paused
        case .success:
            recognizerRingStatusView.backgroundColor = RecognizerStatusColors.success
        }
    }*/
    
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
