//
//  VoiceRecognitionController.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 11/30/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import AVFoundation
import Speech

protocol VoiceRecognitionDelegate {
    func speechRecognized(text: String)
}

class VoiceController: NSObject, SFSpeechRecognizerDelegate {
    
    // Text to Speech
    let speechSynthesizer = AVSpeechSynthesizer()
    
    // Voice Recognition
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    var request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var status = false
    
    // voice recognition delegate
    var voiceHandler: VoiceRecognitionDelegate?
    
    // MARK: TEXT TO SPEECH
    
    func speak(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechSynthesizer.speak(speechUtterance)
    }
    
    // MARK: VOICE RECOGNITION
    
    // initilize and begin recording speech
    func startRecordingSpeech() {
        if !checkSpeechPermissions() {
            return
        }
        
        if status == false {
            setupRecognition()
            startSpeechRecognitionTask()
        }
        
    }
    
    func restartRecordingSpeech() {
        recognitionTask?.finish()
        request = SFSpeechAudioBufferRecognitionRequest()
        startSpeechRecognitionTask()
    }
    
    // set up engine and recognizer
    private func setupRecognition() {
        let node = audioEngine.inputNode //Note: medium guide wanted to guard this. But this is not optional...this is a singleton
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch { // exit on error
            return print(error)
        }
        
        // status checks
        guard let myRecognizer = SFSpeechRecognizer() else { return } // recognizer is not supported for locale
        if !myRecognizer.isAvailable { return } // not available right now
    }
    
    // prepare and start recording
    private func startSpeechRecognitionTask() {
        status = true
        print("debug: starting new session")
        // Call the recognizer
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                // use the string
                if self.voiceHandler != nil {
                    self.voiceHandler?.speechRecognized(text: bestString)
                } else {
                    print("Warning [VoiceController]: No delegate set for voice input handling")
                }
            } else if let error = error {
                print(error)
            }
        })
    }
    
    func checkSpeechPermissions() -> Bool {
        var status = SFSpeechRecognizer.authorizationStatus()
        
        if status == .notDetermined {
            requestPermissionAlert(title: "Speech", message: "Would you like to let the app listen for voice commands? This will only happen while cooking.", from: nil, handler: { (confirmed) in
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
            print("Log [VoiceController]: authorized for voice recognition.")
            return true
        case .denied:
            let warningText = "Permissions for speech recognition were denied. Change permissions in setting to use the app's voice recognition features."
            messageAlert(title: "Warning", message: warningText, from: nil)
            print("Log [VoiceController]:", warningText)
            return false
        case .restricted:
            let warningText = "Speech recognition is restricted on this device."
            messageAlert(title: "Warning", message: warningText, from: nil)
            print("Log [VoiceController]:", warningText)
            return false
        case .notDetermined:
            print("Warning [VoiceController]: Status not determined. How did we get here?")
            return false
        }
    }
}
