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
    func statusUpdated(microphone: VoiceController.MicrophoneStatus, recognizer: VoiceController.RecognitionStatus, speech: VoiceController.SpeakerStatus)
    func microphoneUpdate(status: VoiceController.MicrophoneStatus)
    func activityIndicator(show: Bool, label: String?)
    //func recognitionUpdate(status: VoiceController.RecognitionStatus)
}

protocol VoiceCommandsDelegate {
    func executeCommandStart()
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
    var timeOut: Timer?
    
    // Voice Controller delegates
    var displayDelegate: VoiceStatusDisplayDelegate?
    var commandDelegate: VoiceCommandsDelegate?
    
    // Voice Controller Status Properties
    private var _micStatus: MicrophoneStatus = .disabled
    private var _recStatus: RecognitionStatus = .disabled
    private var _speakStatus: SpeakerStatus = .idle
    
    
    private var microphoneStatus: MicrophoneStatus {
        get { return _micStatus }
        set (value) {
            _micStatus = value
            displayDelegate?.statusUpdated(microphone: _micStatus, recognizer: _recStatus, speech: _speakStatus)
        }
    }
    private var recognitionStatus: RecognitionStatus {
        get { return _recStatus }
        set (value) {
            _recStatus = value
            displayDelegate?.statusUpdated(microphone: _micStatus, recognizer: _recStatus, speech: _speakStatus)
        }
    }
    private var speakerStatus: SpeakerStatus {
        get { return _speakStatus }
        set (value) {
            _speakStatus = value
            displayDelegate?.statusUpdated(microphone: _micStatus, recognizer: _recStatus, speech: _speakStatus)
        }
    }
    
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
    
    // MARK: TEXT TO SPEECH
    
    func speak(text: String) {
        // Fix for audio on normal phone speaker: https://stackoverflow.com/questions/36421802/using-the-iphone-speakers-with-avspeechsynthesizer
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
        } catch { print(error) }
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
        if recognitionStatus != .disabled {
            resumeRecognitionTask()
        }
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
    
    // MARK: VOICE RECOGNITION
    
    // external controls
    // initilize and begin recording speech
    func startRecordingSpeech() {
        print("Log [VoiceController]: Attempting to initialize voice recognition.")
        
        checkSpeechRecognitionPermissions() { speechAuthorized in
            self.displayDelegate?.activityIndicator(show: false, label: nil)
            if speechAuthorized {
                self.recognitionStatus = .inactive
                self.checkMicrophonePermissions() { microphoneAuthorized in
                    self.displayDelegate?.activityIndicator(show: false, label: nil)
                    if microphoneAuthorized {
                        self.microphoneStatus = .off
                        self.speak(text: "Let's start cooking. First gather your ingredients. When you are ready say...start cooking.")
                        self.setupRecognizerEngine()
                        self.startRecognitionTask()
                    } else {
                        self.microphoneStatus = .disabled
                    }
                }
            } else {
                self.recognitionStatus = .disabled
            }
        }
    }
    
    // external functions
    func pauseRecordingSpeech() {
        if speakerStatus == .active {
            speechSynthesizer.pauseSpeaking(at: .word)
        }
        if audioEngine.isRunning {
            displayDelegate?.speechRecognized(text: "")
            pauseRecognitionTask()
        }
    }
    
    func resumeRecordingSpeech() {
        if speakerStatus == .active {
            speechSynthesizer.continueSpeaking()
        }
        if !audioEngine.isRunning {
            displayDelegate?.speechRecognized(text: "")
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
        print("DEBUG [recognitionTask]: start")
        displayDelegate?.speechRecognized(text: "")
        recognitionStatus = .active
        setupRecognitionTask()
        
    }
    
    private func resumeRecognitionTask() {
        startAudioEngine()
        
        // resume recognitionTask
        print("DEBUG [recognitionTask]: resume")
        displayDelegate?.speechRecognized(text: "")
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
                if let error = error {
                    let code =  (error as NSError).code
                    //code=216 on exit
                    //code=209 ???
                    if code == 1 || code == 203 {
                        // code 1 = time out, or maybe finished?
                        // code 203 = empty result/retry
                        print("DEBUG [recognitionTask]: Code \(code): restarting")
                        // restart recognition
                        self.pauseRecognitionTask()
                        self.resumeRecognitionTask()
                    } else if code == 216 {
                        print("DEBUG [recognitionTask]: Code 216: task cancelled.")
                    } else if code == 4 {
                        messageAlert(title: "Internet", message: "Could not process recorded data. Please check your internet connection.", from: nil)
                        self.recognitionStatus = .inactive
                        self.stopRecognitionTask()
                    } else {
                        print("Error [recognitionTask]: results failed.")
                        print(code, error.localizedDescription)
                        print(error)
                    }
                } else if let result = result {
                    // first time result is recieved from a task we need to set a delayed task to restart it, because the 1 minute timeout will not inform us it has killed the task.
                    if self.timeOut == nil {
                        print("DEBUG [recognitionTask]: timeOut set")
                        self.timeOut = Timer.scheduledTimer(withTimeInterval: 60, repeats: false, block: { (timer) in
                            print("DEBUG [recognitionTask]: timeOut triggered")
                            self.pauseRecognitionTask()
                            self.resumeRecognitionTask()
                            self.timeOut = nil
                        })
                    }
                    
                    // get result
                    let bestString = result.bestTranscription.formattedString
                    
                    // update the display text as its processed
                    self.displayDelegate?.speechRecognized(text: bestString)
                    
                    // check for commands
                    self.checkForCommands(result: bestString)
                    // if no command found...start a timer. If there are results in the recognizer then the 1 minute timeout will not cause an error message
                } else {
                    // handle failures here
                    
                    //} else {
                        print("DEBUG [recognitionTask]: no error with no results")
                    //}
                }
            }
        })
    }
    
    // release engine nad recognizer
    private func stopRecognitionTask() {
        print("Log [VoiceController]: Stopping voice recognition services.")
        
        // stop using the microphone
        print("DEBUG [audioEngine]: stop")
        microphoneStatus = .off
        request.endAudio() // Added line to mark end of recording
        audioEngine.stop()
        print("DEBUG [audioEngine]: remove tap")
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionStatus = .inactive
        // stop the recognition task if it is running
        print("DEBUG [recognitionTask]: stop")
        recognitionTask?.cancel()
        recognitionTask = nil
        if let timer = timeOut {
            timer.invalidate()
            timeOut = nil
        }
    }
    
    private func pauseRecognitionTask() {
        print("DEBUG [recognitionTask]: cancel")
        recognitionStatus = .inactive
        recognitionTask?.cancel() // using finish results in an error code 1, which is the same for timeout
        recognitionTask = nil
        if let timer = timeOut {
            timer.invalidate()
            timeOut = nil
        }
        
        print("DEBUG [audioEngine]: pause")
        microphoneStatus = .off
        audioEngine.pause()
    }
    
    // audio engine start helper function
    private func startAudioEngine() {
        print("DEBUG [audioEngine]: start")
        do {
            try audioEngine.start()
            microphoneStatus = .listening
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
        } else if result.contains("start cooking") {
            pauseRecognitionTask()
            
            speakerStatus = .active
            displayDelegate?.speechRecognized(text: "start cooking")
            commandDelegate?.executeCommandStart()
        } else if result.contains("list ingredients") {
            pauseRecognitionTask()
            
            speakerStatus = .active
            displayDelegate?.speechRecognized(text: "list ingredients")
            commandDelegate?.executeCommandListIngredients()
        }
    }
    
    // MARK: PERMISSIONS CHECK FUNCTIONS
    
    func checkMicrophonePermissions(completion handler: @escaping (Bool)->Void) {
        displayDelegate?.activityIndicator(show: true, label: "Permissions...")
        let permissions = AVAudioSession.sharedInstance().recordPermission()
        
        switch permissions {
        case .undetermined:
            //displayDelegate?.activityIndicator(show: true, label: "Asking Microphone")
            requestPermissionAlert(title: "Microphone", message: "Would you like to give the app permission to use the microphone in order to hear your voice commnds? Only while cooking)", from: nil, handler: { (confirmed) in
                if confirmed {
                    self.displayDelegate?.activityIndicator(show: true, label: "Authorizing...")
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
        displayDelegate?.activityIndicator(show: true, label: "Permissions...")
        var permissions = SFSpeechRecognizer.authorizationStatus()
        //displayDelegate?.activityIndicator(show: false, label: nil)
        
        switch permissions {
        case .notDetermined:
            //displayDelegate?.activityIndicator(show: true, label: "Asking Recognition")
            requestPermissionAlert(title: "Speech Recognition", message: "Would you like to let the app listen for voice commands? This will only happen while cooking.", from: nil, handler: { (confirmed) in
                if confirmed {
                    self.displayDelegate?.activityIndicator(show: true, label: "Authorizing...")
                    SFSpeechRecognizer.requestAuthorization { (authorizationStatus) in
                        //self.displayDelegate?.activityIndicator(show: false, label: nil)
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
