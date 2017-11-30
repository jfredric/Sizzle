//
//  RecipeTableViewController.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 11/27/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class RecipeTableViewController: UIViewController, SFSpeechRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var speechRecognizerLabel: UILabel!
    
    // Speech
    let speechSynthesizer = AVSpeechSynthesizer()
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?

    
    var currentRecipe: Recipe!
    
    // MARK: SPEECH DELEGATE AND FUNCTIONS
    
    func recordAndRecognizeSpeech() {
        
        // set up engine and recognizer
        let node = audioEngine.inputNode //Note: medium guide wanted to guard this. But this is not optional...this is a singleton
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        // prepare and start recording
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch { // exit on error
            return print(error)
        }
        
        // status checks
        guard let myRecognizer = SFSpeechRecognizer() else { return } // recognizer is not supported for locale
        if !myRecognizer.isAvailable { return } // not available right now
        
        // Call the recognizer
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                // use the string
                self.speechRecognizerLabel.text = bestString
            } else if let error = error {
                print(error)
            }
        })
        
        
    }
    
    // MARK: ACTION FUNCTIONS
    
    @IBAction func startTapped(_ sender: UIBarButtonItem) {
        // begin voice recognition
        
        var status = SFSpeechRecognizer.authorizationStatus()
        
        if status == .notDetermined {
            requestPermissionAlert(title: "Speech", message: "Would you like to let the app listen for voice commands? This will only happen while cooking.", from: self, handler: { (confirmed) in
                if confirmed {
                    SFSpeechRecognizer.requestAuthorization { (authorizationStatus) in
                        status = authorizationStatus
                        if status == .denied {
                            print("Warning [RecipeView]: User has denied speech recognition permissions")
                        }
                    }
                }
            })
        }
        
        switch status {
        case .authorized:
            print("authorized")
            recordAndRecognizeSpeech()
            // do the stuff
        case .denied:
            messageAlert(title: "Warning", message: "Permissions for speech recognition were denied. Change permissions in setting to use the app's voice recognition features.", from: self)
        case .restricted:
            messageAlert(title: "Warning", message: "Speech recognition is restricted on this device.", from: self)
        case .notDetermined:
            print("Warning [RecipeView]: Status not determined. How did we get here?")
        }
    }
    
    // MARK: VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let speechUtterance = AVSpeechUtterance(string: speechText)
        speechSynthesizer.speak(speechUtterance)
    }

}
