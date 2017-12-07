//
//  RecipeTableViewController.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 11/27/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.HomeTableViewCell
//

import UIKit

class RecipeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, VoiceStatusDisplayDelegate, RecipeProgressViewDelegate {
    
    // MARK: PROPERTIES
    
    // UI Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var speechRecognizerLabel: UILabel!
    @IBOutlet weak var startButton: UIBarButtonItem!
    @IBOutlet weak var microphoneImageView: UIImageView!
    //@IBOutlet weak var recognizerRingStatusView: UIView!
    @IBOutlet weak var statusBoxView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var currentRecipe: Recipe!
    
    var voiceController = VoiceController()
    
    // MARK: CONSTANTS
    
    // Microphone Status Colors
    let microphoneActiveColor = UIColor(red: 0.2353, green: 0.4863, blue: 0.7608, alpha: 1.0) // blue
    // UIColor(red: 0.84, green: 0.84, blue: 0.84, alpha: 1.0) // same light level gray
    let microphoneIdleColor = UIColor.lightGray
    let microphoneDisabledColor = UIColor.gray
    
    
    // MARK: ACTION FUNCTIONS
    
    // "Start" button, for start, pause and resume
    @IBAction func startTapped(_ sender: UIBarButtonItem) {
        switch startButton.title ?? "nil" {
        case "Start" :
            // turn the screen idle timer off. If the screen locks the app closes.
            UIApplication.shared.isIdleTimerDisabled = true
            
            // begin voice recognition
            voiceController.startRecordingSpeech()
            
            // Change button state
            startButton.title = "Pause"
        case "Pause" :
            voiceController.pauseRecordingSpeech()
            startButton.title = "Resume"
            UIApplication.shared.isIdleTimerDisabled = false
        case "Resume" :
            UIApplication.shared.isIdleTimerDisabled = true
            voiceController.resumeRecordingSpeech()
            startButton.title = "Pause"
        default :
            print("Error [RecipeView]: Button not labeled correctly.")
        }
    }
    
    // MARK: VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()

        // dynamic cell properties
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        // Set various delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        voiceController.displayDelegate = self
        voiceController.commandDelegate = currentRecipe
        
        currentRecipe.dictateDelegate = voiceController
        currentRecipe.progressViewDelegate = self
        
        microphoneImageView.tintColor = microphoneDisabledColor
        
        navigationItem.title = currentRecipe.title
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController { // https://stackoverflow.com/questions/27713747/execute-action-when-back-bar-button-of-uinavigationcontroller-is-pressed/27715660#27715660
            // stop any voice recognition
            voiceController.stopRecordingSpeech()
            // do I need to clean up the recipe? No it should be deallocated.
        }
    }
    
    // MARK: RECIPE DELEGATE
    func recipeStart() {
//        // disable button
//        startButton.isEnabled = false
        startButton.title = "Pause"
    }
    
    func recipeFinished() {
        // display alert???
        
        // enable start button
        startButton.isEnabled = true
        tableView.selectRow(at: nil, animated: true, scrollPosition: UITableViewScrollPosition.top)
        startButton.title = "Start"
    }
    
    func moveTo(step: Int) {
        let indexPath = IndexPath(row: step, section: 1)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.top)
    }
    
    // MARK: VOICE CONTROLLER DELEGATE
    
    func speechRecognized(text: String) {
        speechRecognizerLabel.text = text
    }
    
    func statusUpdated(microphone: VoiceController.MicrophoneStatus, recognizer: VoiceController.RecognitionStatus, speech: VoiceController.SpeakerStatus) {
        if speech == .active {
            startButton.isEnabled = false
        } else {
            startButton.isEnabled = true
        }
        
        switch microphone {
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
    
    func activityIndicator(show: Bool, label: String?) {
        DispatchQueue.main.async {
            self.statusBoxView.isHidden = !show
            self.statusLabel.text = label
            if show {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
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
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        } else {
            return currentRecipe.stepCount
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Ingredients"
        } else {
            return "Instructions"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = (tableView.dequeueReusableCell(withIdentifier: "StepTableViewCell-ID", for: indexPath) as? RecipeStepTableViewCell) else {
            fatalError("Error [Recipe Steps]: Could not cast cell as RecipeStepTableViewCell")
        }
        
        // Configure the cell...
        if indexPath.section == 0 {
            cell.instructionsLabel.text = currentRecipe.ingredientsListAsTextBlock()
        } else {
            cell.instructionsLabel.text = currentRecipe.stepText(forViewAt: indexPath.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if startButton.isEnabled { // so you cannot queue up a bunch of cell presses once dictation is happening
            currentRecipe.jumpTo(step: indexPath.row, sender: self)
        }
    }

}
