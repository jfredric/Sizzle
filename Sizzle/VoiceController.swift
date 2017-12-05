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
    var recognitionStatus: RecognitionStatus = .disabled
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
        case success // not currently used, may not need
        case inactive
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
        
        // pause recognition if running
        if recognitionStatus == .active {
            pauseRecognitionTask()
        }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        // code here
        //print("DEBUG [speech]: will speak")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("DEBUG [speech]: did finish")
        
        speakerStatus = .idle
        
        // resume recognition
        // need a check for if it is paused while speaking?f
        resumeRecognitionTask()
    }
    
    // MARK: RECIPE DICTATE DELEGATE
    func dictate(stepText: String) {
        // check recognizer state
        speak(text: stepText)
    }
    
    func dictateFinished() {
        displayDelegate?.speechRecognized(text: "")
        stopRecognitionTask()
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
    
    // external controls
    // initilize and begin recording speech
    func startRecordingSpeech() {
        print("Log [VoiceController]: Attempting to initialize voice recognition.")
        checkSpeechRecognitionPermissions() { speechAuthorized in
            if speechAuthorized {
//                self.updateRecognition(status: .paused)
                self.checkMicrophonePermissions() { microphoneAuthorized in
                    if microphoneAuthorized {
                        self.updateMicrophone(status: .off)
                        self.setupRecognizerEngine()
                        self.startRecognitionTask()
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
        if speakerStatus == .active {
            speechSynthesizer.pauseSpeaking(at: .word)
        }
        if audioEngine.isRunning {
            pauseRecognitionTask()
        }
    }
    
    func resumeRecordingSpeech() {
        if speakerStatus == .active {
            speechSynthesizer.continueSpeaking()
        }
        if !audioEngine.isRunning {
            resumeRecognitionTask()
        }
    }
    func stopRecordingSpeech() {
        stopRecognitionTask()
    }
    
    // internal state functions
    // set up engine and recognizer
    private func setupRecognizerEngine() {
        print("Log [VoiceController]: Configuring voice recognition properties.")
        
        print("DEBUG [audioEngine]: setup node and tap")
        let node = audioEngine.inputNode //Note: medium guide wanted to guard this. But this is not optional...this is a singleton
        let recordingFormat = node.outputFormat(forBus: 0)
        //let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        print("DEBUG [audioEngine]: prepare")
        audioEngine.prepare()
        startAudioEngine()
        
        // status checks
        guard let myRecognizer = SFSpeechRecognizer() else { return } // recognizer is not supported for locale
        if !myRecognizer.isAvailable { return } // not available right now
    }
    
    // start recording
    private func startRecognitionTask() {
        print("Log [VoiceController]: Starting voice recognition session.")
        
        // make sure the results text field is empty
        //displayDelegate?.speechRecognized(text: "")
        print("DEBUG [recognitionTask]: start")
        recognitionStatus = .active
        setupRecognitionTask()
        
    }
    
    private func resumeRecognitionTask() {
        startAudioEngine()
        
        // resume recognitionTask
        print("DEBUG [recognitionTask]: resume")
        recognitionStatus = .active
        setupRecognitionTask()
    }
    
    private func setupRecognitionTask() {
        // get a new recognitionRequest
        print("DEBUG [recognitionTask]: new request")
        request = SFSpeechAudioBufferRecognitionRequest() // was complaining about something. Double check
        
        // set up the recognizer
        print("DEBUG [recognitionTask]: new task")
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if self.speakerStatus != .active { // safety fencing in case recognizer picks up speech synthesis
                if let result = result {
                    let bestString = result.bestTranscription.formattedString
                    
                    // update the display text as its processed
                    self.displayDelegate?.speechRecognized(text: bestString)
                    
                    // check for commands
                    self.checkForCommands(result: bestString)
                } else {
                    // handle failures here
                    print("Error [recognitionTask]: results failed.")
                    if let error = error {
                        print(error)
                    }
                }
            }
        })
    }
    
    // release engine nad recognizer
    private func stopRecognitionTask() {
        print("Log [VoiceController]: Stopping voice recognition services.")
        recognitionStatus = .inactive
        // stop the recognition task if it is running
        print("DEBUG [recognitionTask]: stop")
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // stop using the microphone
        print("DEBUG [audioEngine]: stop")
        updateMicrophone(status: .off)
        request.endAudio() // Added line to mark end of recording
        audioEngine.stop()
        print("DEBUG [audioEngine]: remove tap")
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    private func pauseRecognitionTask() {
        
        print("DEBUG [recognitionTask]: cancel")
        recognitionStatus = .inactive
        recognitionTask?.cancel() // better than finish???
        recognitionTask = nil
        
        print("DEBUG [audioEngine]: pause")
        updateMicrophone(status: .off)
        audioEngine.pause()
    }
    
    // audio engine start helper function
    private func startAudioEngine() {
        print("DEBUG [audioEngine]: start")
        do {
            try audioEngine.start()
            updateMicrophone(status: .listening)
        } catch { // exit on error
            print("Error [audioEngine]: could not start")
            return print(error)
        }
    }
    
    // MARK: COMMANDS helper funciton
    
    private func checkForCommands(result: String) {
        let result = result.lowercased()
        if result.contains("next") {
            pauseRecognitionTask()
            
            speakerStatus = .active
            displayDelegate?.speechRecognized(text: "next")
            commandDelegate?.executeCommandNext()
        } else if result.contains("previous") {
            pauseRecognitionTask()
            
            speakerStatus = .active
            displayDelegate?.speechRecognized(text: "previous")
            commandDelegate?.executeCommandPrev()
        } else if result.contains("repeat") {
            pauseRecognitionTask()
            
            speakerStatus = .active
            displayDelegate?.speechRecognized(text: "repeat")
            commandDelegate?.executeCommandRepeat()
        } else if result.contains("stop cooking") {
            pauseRecognitionTask()
            
            speakerStatus = .active
            displayDelegate?.speechRecognized(text: "stop cooking")
            commandDelegate?.executeCommandStop()
        } else if result.contains("list ingredients") {
            pauseRecognitionTask()
            
            speakerStatus = .active
            displayDelegate?.speechRecognized(text: "list ingredients")
            commandDelegate?.executeCommandListIngredients()
        }
    }
    
    // MARK: PERMISSIONS CHECK FUNCTIONS
    
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
