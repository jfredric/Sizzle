//
//  VoiceController.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 11/30/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import AVFoundation
import Speech

protocol VoiceStatusDisplayDelegate {
    func speechRecognized(text: String)
    func microphoneUpdate(status: VoiceController.MicrophoneStatus)
    //func recognitionUpdate(status: VoiceController.RecognitionStatus)
}

protocol VoiceCommandsDelegate {
    func executeCommandNext()
    func executeCommandPrev()
    func executeCommandStop()
    func executeCommandRepeat()
    func executeCommandListIngredients()
}

class VoiceController: NSObject, SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate, AVSpeechSynthesizerDelegate, RecipeDictateDelegate {
    
    //MARK: PROPERTIES
    
    // Text to Speech
    let speechSynthesizer = AVSpeechSynthesizer()
    
    // Voice Recognition
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    var request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    // Voice Controller delegates
    var displayDelegate: VoiceStatusDisplayDelegate?
    var commandDelegate: VoiceCommandsDelegate?
    
    // Voice Controller Status Properties
    //var voiceControllerStatus: VoicecControllerStatus = .idle
    var microphoneStatus: MicrophoneStatus = .disabled
    //var recognitionStatus: RecognitionStatus = .disabled
    var speakerStatus: SpeakerStatus = .idle
    
    // MARK: ENUMS & STRUCTURES
    
    enum SpeakerStatus {
        case active
        case idle
        case disabled
    }
    
    enum MicrophoneStatus {
        case disabled
        case listening
        case off
    }
    
    enum RecognitionStatus {
        case disabled
        case active
        case success
        case paused
    }
    
    // MARK: INITIALIZER
    
    override init() {
        super.init()
        
        // set speech delegates
        speechSynthesizer.delegate = self
        speechRecognizer?.delegate = self
    }
    
    // MARK: HELPER FUNCTIONS
    
    func updateMicrophone(status: MicrophoneStatus) {
        microphoneStatus = status
        displayDelegate?.microphoneUpdate(status: status)
    }
    
    /*func updateRecognition(status: RecognitionStatus) {
        recognitionStatus = status
        displayDelegate?.recognitionUpdate(status: status)
    }*/
    
    // MARK: TEXT TO SPEECH
    
    func speak(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechSynthesizer.speak(speechUtterance)
    }
    
    // AVSpeechSynthesizerDelegate functions
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("DEBUG [speech]: did start")
        
        speakerStatus = .active
        
        // pause recognition
        recognitionTask?.finish()
//        if recognitionStatus != .disabled {
//            updateRecognition(status: .paused)
//        }
        if microphoneStatus != .disabled {
            updateMicrophone(status: .off)
        }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        // code here
        print("DEBUG [speech]: did pause")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        // code here
        print("DEBUG [speech]: did continue")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        // code here
        //print("DEBUG [speech]: will speak")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        // code here
        print("DEBUG [speech]: did cancel")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("DEBUG [speech]: did finish")
        
        speakerStatus = .idle
        
        // resume recognition
        startSpeechRecognitionTask()
    }
    
    // MARK: RECIPE DICTATE DELEGATE
    func dictate(stepText: String) {
        speak(text: stepText)
    }
    
    func dictateFinished() {
        displayDelegate?.speechRecognized(text: "")
        stopRecognition()
    }
    
    // MARK: SFSpeechRecognizerDelegate (optional)
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        // CODE HERE
        print("DEBUG [recognizer]: availability changed to", available)
    }
    
    // MARK: SFSpeechRecognitionTaskDelegate (optional)
    
    /*** This is very very slow and not very useful
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        print("DEBUG [recog. task]: speech detected.")
    }
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        print("DEBUG [recog. task]: did finish with: ", recognitionResult.bestTranscription.formattedString)
    }
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print("DEBUG [recog. task]: did finish successfully (\(successfully))")
    }
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        print("DEBUG [recog. task]: finished reading audio.")
    }
    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        print("DEBUG [recog. task]: recognition was cancelled.")
    }
     ***/
    
    // MARK: VOICE RECOGNITION
    
    // initilize and begin recording speech
    func startRecordingSpeech() {
        print("Log [VoiceController]: Attempting to initialize voice recognition.")
        checkSpeechRecognitionPermissions() { speechAuthorized in
            if speechAuthorized {
//                self.updateRecognition(status: .paused)
                self.checkMicrophonePermissions() { microphoneAuthorized in
                    if microphoneAuthorized {
                        self.updateMicrophone(status: .off)
                        self.setupRecognition()
                        self.startSpeechRecognitionTask()
                    } else {
                        self.updateMicrophone(status: .disabled)
                    }
                }
            } else {
                self.updateMicrophone(status: .disabled)
            }
        }
    }
    func pauseRecordingSpeech() {
        if audioEngine.isRunning {
            audioEngine.pause()
            recognitionTask?.finish()
            updateMicrophone(status: .off)
        }
    }
    func resumeRecordingSpeech() {
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
                updateMicrophone(status: .listening)
            } catch { // exit on error
                return print(error)
            }
            startSpeechRecognitionTask()
            updateMicrophone(status: .listening)
        }
    }
    func stopRecordingSpeech() {
        stopRecognition()
    }
    
    // set up engine and recognizer
    private func setupRecognition() {
        print("Log [VoiceController]: Configuring voice recognition properties.")
        let node = audioEngine.inputNode //Note: medium guide wanted to guard this. But this is not optional...this is a singleton
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            updateMicrophone(status: .listening)
        } catch { // exit on error
            return print(error)
        }
        
        // status checks
        guard let myRecognizer = SFSpeechRecognizer() else { return } // recognizer is not supported for locale
        if !myRecognizer.isAvailable { return } // not available right now
    }
    
    // release engine nad recognizer
    private func stopRecognition() {
        print("Log [VoiceController]: Stopping voice recognition services.")
        
        // stop using the microphone
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // stop the recognition task if it is running
        recognitionTask?.cancel()
        
        //        if recognitionStatus != .disabled {
        //            updateRecognition(status: .paused)
        //        }
        if microphoneStatus != .disabled {
            updateMicrophone(status: .off)
        }
    }
    
    // start recording
    private func startSpeechRecognitionTask() {
        print("Log [VoiceController]: Starting voice recognition session.")
        
        //get a new recognitionRequest
        request = SFSpeechAudioBufferRecognitionRequest()
        
        //voiceControllerStatus = .recognizing
//        if recognitionStatus != .disabled {
//            updateRecognition(status: .active)
//        }
        if microphoneStatus != .disabled {
            updateMicrophone(status: .listening)
        }
        
        // Call the recognizer
        //recognitionTask = speechRecognizer?.recognitionTask(with: request, delegate: self)
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if self.speakerStatus != .active { // safety fencing in case recognizer picks up speech synthesis
                if let result = result {
                    let bestString = result.bestTranscription.formattedString

                    // update the display text
                    self.displayDelegate?.speechRecognized(text: bestString)

                    // check for commands
                    
                    if bestString.lowercased().contains("next") {
                        //self.voiceControllerStatus = .dictating
                        self.speakerStatus = .active
                        self.recognitionTask?.finish()
                        self.displayDelegate?.speechRecognized(text: "next")
                        self.commandDelegate?.executeCommandNext()
                    } else if bestString.lowercased().contains("previous") {
                        self.speakerStatus = .active
                        self.recognitionTask?.finish()
                        self.displayDelegate?.speechRecognized(text: "previous")
                        self.commandDelegate?.executeCommandPrev()
                    } else if bestString.lowercased().contains("repeat") {
                        self.speakerStatus = .active
                        self.recognitionTask?.finish()
                        self.displayDelegate?.speechRecognized(text: "repeat")
                        self.commandDelegate?.executeCommandRepeat()
                    } else if bestString.lowercased().contains("stop cooking") {
                        self.speakerStatus = .active
                        self.stopRecognition()
                        self.displayDelegate?.speechRecognized(text: "stop cooking")
                        self.commandDelegate?.executeCommandStop()
                    } else if bestString.lowercased().contains("list ingredients") {
                        self.speakerStatus = .active
                        self.recognitionTask?.finish()
                        self.displayDelegate?.speechRecognized(text: "list ingredients")
                        self.commandDelegate?.executeCommandListIngredients()
                    }

                } else if let error = error {
                    print(error)
                }
            }
        })
        
    }
    
    func checkMicrophonePermissions(completion handler: @escaping (Bool)->Void) {
        let permissions
            = AVAudioSession.sharedInstance().recordPermission()
        
        switch permissions {
        case .undetermined:
            requestPermissionAlert(title: "Microphone", message: "Would you like to give the app permission to use the microphone in order to hear your voice commnds? Only while cooking)", from: nil, handler: { (confirmed) in
                if confirmed {
                    AVAudioSession.sharedInstance().requestRecordPermission() { (authorized) in
                        if authorized {
                            print("Log [VoiceController]: User authorized app to use the microphone")
                            handler(true)
                        } else {
                            print("Warning [VoiceController]: User has denied microphone permissions")
                            handler(false)
                        }
                        
                    }
                } else {
                    handler(false)
                }
            })
        case .denied:
            let warningText = "Permissions for microphone usage were denied. Change permissions in setting to use the app's voice recognition features."
            messageAlert(title: "Warning", message: warningText, from: nil)
            print("Log [VoiceController]:", warningText)
            handler(false)
        case .granted:
            print("Log [VoiceController]: Authorized for microphone use.")
            handler(true)
        }
        //requestRecordPermission
    }
    
    func checkSpeechRecognitionPermissions(completion handler: @escaping (Bool)->Void) {
        var permissions = SFSpeechRecognizer.authorizationStatus()
        
        switch permissions {
        case .notDetermined:
            requestPermissionAlert(title: "Speech Recognition", message: "Would you like to let the app listen for voice commands? This will only happen while cooking.", from: nil, handler: { (confirmed) in
                if confirmed {
                    SFSpeechRecognizer.requestAuthorization { (authorizationStatus) in
                        permissions = authorizationStatus
                        if permissions == .denied {
                            print("Warning [VoiceController]: User has denied speech recognition permissions")
                            handler(false)
                        }
                        if permissions == .authorized {
                            print("Log [VoiceController]: User authorized app for voice recognition")
                            handler(true)
                        }
                    }
                } else {
                    handler(false)
                }
            })
        case .authorized:
            print("Log [VoiceController]: authorized for voice recognition.")
            handler(true)
        case .denied:
            let warningText = "Permissions for speech recognition were denied. Change permissions in setting to use the app's voice recognition features."
            messageAlert(title: "Warning", message: warningText, from: nil)
            print("Log [VoiceController]:", warningText)
            handler(false)
        case .restricted:
            let warningText = "Speech recognition is restricted on this device."
            messageAlert(title: "Warning", message: warningText, from: nil)
            print("Log [VoiceController]:", warningText)
            handler(false)
        }
    }
}
