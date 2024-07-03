//
//  ContentView.swift
//  JustTalk
//
//  Created by Rodney Gainous Jr on 7/2/24.
//

import SwiftUI
import AVFoundation
import OpenAI

struct ContentView: View {
    @State private var recordedText = ""
    @State private var transformedText = ""
    @State private var isRecording = false
    @State private var isPaused = false
    @State private var selectedTransformation = 0
    @State private var hasRecording = false
    
    @State private var isTransforming = false
    @State private var isTransformButtonDisabled = true
    
    let transformations = ["Text", "Email", "Summary", "Story"]
    
    // Audio recording properties
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioFilename: URL?
    
    // OpenAI client
    let openAI = OpenAI(apiToken: "")
    
    // Audio settings
    let settings = [
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 1,
        AVLinearPCMBitDepthKey: 16,
        AVLinearPCMIsBigEndianKey: false,
        AVLinearPCMIsFloatKey: false,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ] as [String : Any]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    recordingSection
                    
                    Divider()
                    
                    transformationSection
                    
                    Divider()
                    
                    debugSection
                    
                    if !transformedText.isEmpty {
                        Divider()
                        transformedTextView
                    }
                }
                .padding()
            }
            .navigationTitle("JustTalk")
        }
        .onAppear {
            setupAudioSession()
        }
    }
    
    var recordingSection: some View {
        VStack(spacing: 20) {
            recordButton
            
            if isRecording || hasRecording {
                pauseResumeButton
            }
            
            audioFileInfo
        }
    }
    
    var transformationSection: some View {
        VStack(spacing: 20) {
            transformationPicker
            transformButton
        }
    }
    
    var debugSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Debug Information")
                .font(.headline)
            debugInfo
        }
    }
    
    var recordButton: some View {
        Button(action: toggleRecording) {
            VStack {
                Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(isRecording ? .red : .blue)
                Text(recordingStatusText)
                    .font(.subheadline)
            }
        }
    }
    
    var pauseResumeButton: some View {
        Button(action: togglePause) {
            Text(isPaused ? "Resume" : "Pause")
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(!isRecording)
    }
    
    var debugInfo: some View {
        VStack(alignment: .leading) {
            Text("Recording: \(isRecording ? "Yes" : "No")")
            Text("Has Recording: \(hasRecording ? "Yes" : "No")")
            Text("Transform Disabled: \(isTransformButtonDisabled ? "Yes" : "No")")
        }
        .font(.footnote)
        .foregroundColor(.gray)
    }
    
    var audioFileInfo: some View {
        Group {
            if let audioFilename = audioFilename {
                Text("Audio File: \(audioFilename.lastPathComponent)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    var transformationPicker: some View {
        VStack {
            Text("Choose Transformation")
                .font(.headline)
            Picker("Transformation", selection: $selectedTransformation) {
                ForEach(0..<transformations.count) { index in
                    Text(transformations[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    var transformButton: some View {
        Button(action: transcribeAndTransform) {
            Text("Transform Text")
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background((!hasRecording || isTransformButtonDisabled) ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(!hasRecording || isTransformButtonDisabled)
        .overlay(
            Group {
                if isTransforming {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        )
    }
    
    var transformedTextView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Transformed Text")
                .font(.headline)
            ScrollView {
                Text(transformedText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .frame(maxHeight: 200)
        }
    }
    
    var recordingStatusText: String {
        if isRecording {
            return isPaused ? "Paused" : "Recording..."
        } else {
            return hasRecording ? "Recording Complete" : "Tap to Record"
        }
    }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func togglePause() {
        isPaused.toggle()
        if isPaused {
            audioRecorder?.pause()
            
            DispatchQueue.main.async {
                self.isPaused = true
                self.isRecording = false
                self.hasRecording = true
                self.isTransformButtonDisabled = false
                print("Recording paused. hasRecording: \(self.hasRecording), isTransformButtonDisabled: \(self.isTransformButtonDisabled)")
            }
        } else {
            audioRecorder?.record()
        }
    }
    
    func toggleRecording() {
        if isRecording {
            print("Stopping recording")
            stopRecording()
            DispatchQueue.main.async {
                self.hasRecording = true
                print("hasRecording set to true in toggleRecording")
            }
        } else {
            print("Starting recording")
            startRecording()
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        DispatchQueue.main.async {
            self.isRecording = false
            self.isPaused = false
            self.hasRecording = true
            self.isTransformButtonDisabled = false
            print("Recording stopped. hasRecording: \(self.hasRecording), isTransformButtonDisabled: \(self.isTransformButtonDisabled)")
        }
        
        if let audioFilename = audioFilename {
            let fileExists = FileManager.default.fileExists(atPath: audioFilename.path)
            let fileSize = (try? FileManager.default.attributesOfItem(atPath: audioFilename.path)[.size] as? Int64) ?? 0
            print("Audio file exists: \(fileExists)")
            print("Audio file size: \(fileSize) bytes")
            
            if fileExists && fileSize > 0 {
                DispatchQueue.main.async {
                    self.hasRecording = true
                    print("hasRecording set to true based on file existence and size")
                }
            }
        }
    }
    
    func startRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        audioFilename = documentsPath.appendingPathComponent("recording.wav")
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename!, settings: settings)
            audioRecorder?.record()
            DispatchQueue.main.async {
                self.isRecording = true
                self.isPaused = false
                self.hasRecording = false
                self.isTransformButtonDisabled = true
                print("Recording started. isRecording: \(self.isRecording), hasRecording: \(self.hasRecording), isTransformButtonDisabled: \(self.isTransformButtonDisabled)")
            }
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    func transcribeAndTransform() {
        print("Transcribing and transforming")
        guard let audioFilename = audioFilename else {
            print("No audio filename")
            return
        }
        
        print("Audio file path: \(audioFilename.path)")
        print("Audio file exists: \(FileManager.default.fileExists(atPath: audioFilename.path))")
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: audioFilename.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            print("Audio file size: \(fileSize) bytes")
            
            let audioData = try Data(contentsOf: audioFilename)
            print("Audio data size: \(audioData.count) bytes")
            
            // Print the first few bytes of the audio file to check its header
            let headerData = audioData.prefix(16)
            print("Audio file header: \(headerData.map { String(format: "%02X", $0) }.joined())")
            
            // Explicitly set the file type to .wav
            let query = AudioTranscriptionQuery(file: audioData, fileType: .wav, model: .whisper_1)
            
            openAI.audioTranscriptions(query: query) { result in
                switch result {
                case .success(let transcription):
                    print("Transcription successful")
                    DispatchQueue.main.async {
                        self.recordedText = transcription.text
                        self.transformText()
                    }
                case .failure(let error):
                    print("Transcription failed: \(error)")
                    print("Error description: \(error.localizedDescription)")
                    
                    // Print more details about the error
                    if let nsError = error as NSError? {
                        print("Error domain: \(nsError.domain)")
                        print("Error code: \(nsError.code)")
                        if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
                            print("Underlying error: \(underlyingError)")
                        }
                    }
                }
            }
        } catch {
            print("Error reading audio file: \(error)")
        }
    }
    
    func transformText() {
        let prompt = getPromptForTransformation(selectedTransformation)
        let fullPrompt = prompt + recordedText
        
        let query = ChatQuery(messages: [.init(role: .user, content: fullPrompt)!], model: .gpt4_o, temperature: 0.7)
    
        
        var streamedResponse = ""
        
        openAI.chats(query: query) { result in
            switch result {
            case .success(let chatResult):
                if let text = chatResult.choices.first?.message.content?.string {
                    streamedResponse += text
                    DispatchQueue.main.async {
                        self.transformedText = streamedResponse
                    }
                }
            case .failure(let error):
                print("Transformation failed: \(error)")
            }
        }
    }
    
    func getPromptForTransformation(_ index: Int) -> String {
        switch index {
        case 0:
            return "Transform the following text into a concise, clear casual text message: "
        case 1:
            return "Transform the following text into a concise, clear email: "
        case 2:
            return "Transform the following text into a concise, clear summary: "
        case 3:
            return "Transform the following text into a concise, clear story with a smooth transitions, that sounds good when spoken out loud: "
        default:
            return "Transform the following text: "
        }
    }
}

#Preview {
    ContentView()
}
