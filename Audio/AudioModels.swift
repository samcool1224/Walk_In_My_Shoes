//
//  AudioModels.swift
//  Walk In My Shoes
//
//  Created by Samaksh Bhargav on 2/24/25.
//
import SwiftUI
import AVFoundation
@available(iOS 13, *)
public enum SimulationType {
    case normal
    case suddenLoss
    case presbycusis
    case tinnitus
}

// Enhanced Button Components
@available(iOS 13, *)
public struct AudioControlButton: View {
    let icon: String
    let text: String
    let colors: [Color]
    let action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(text)
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 25)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }
}
@available(iOS 17, *)
public struct NavigationButton: View {
    let icon: String
    let colors: [Color]
    let action: () -> Void
    let isDisabled: Bool
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding(12)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isDisabled ? [.gray.opacity(0.3)] : colors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .disabled(isDisabled)
    }
}


// MARK: - Updated Audio Manager with Enhanced Recording Management
@available(iOS 13, *)
@MainActor
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private let audioProcessor = AudioProcessor()
    @Published private(set) var isRecording = false
    @Published private(set) var hasRecording = false
    
    func startRecording() {
        audioProcessor.startRecording()
        isRecording = true
    }
    
    func stopRecording() {
        audioProcessor.stopRecording()
        isRecording = false
        hasRecording = true
    }
    @available(iOS 17, *)
    func playSimulation(for simulationType: AudioChapter.SimulationType) {
        guard hasRecording else { return }
        
        switch simulationType {
        case .normal:
            audioProcessor.playNormal()
        case .tinnitus:
            audioProcessor.playWithTinnitus()
        case .suddenLoss:
            audioProcessor.playWithSuddenLoss()
        case .presbycusis:
            audioProcessor.playWithPresbycusis()
        }
    }
    
    func resetRecording() {
        audioProcessor.stop()
        hasRecording = false
    }
    
    func stopAudio() {
        audioProcessor.stop()
    }
}

// MARK: Audio Class
@available(iOS 13, *)
class AudioProcessor {
    private var audioEngine: AVAudioEngine
    private var playerNode: AVAudioPlayerNode
    private var tinnitusSoundNode: AVAudioPlayerNode
    private var mixerNode: AVAudioMixerNode
    private var effectNode: AVAudioUnitTimePitch
    private var recorder: AVAudioRecorder?
    private var audioFile: AVAudioFile?
    
    init() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        tinnitusSoundNode = AVAudioPlayerNode()
        mixerNode = AVAudioMixerNode()
        effectNode = AVAudioUnitTimePitch()
        
        setupAudioSession()
        setupAudioEngine()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        // Add nodes to engine
        audioEngine.attach(playerNode)
        audioEngine.attach(tinnitusSoundNode)
        audioEngine.attach(mixerNode)
        audioEngine.attach(effectNode)
        
        // Connect nodes
        audioEngine.connect(playerNode, to: mixerNode, format: nil)
        audioEngine.connect(tinnitusSoundNode, to: mixerNode, format: nil)
        audioEngine.connect(mixerNode, to: effectNode, format: nil)
        audioEngine.connect(effectNode, to: audioEngine.mainMixerNode, format: nil)
    }
    
    private func resetAudioEngine() {
        stop()
        audioEngine.stop()
        
        // Reset all nodes
        playerNode.reset()
        tinnitusSoundNode.reset()
        mixerNode.reset()
        effectNode.reset()
        
        // Reset effects
        effectNode.pitch = 0
        effectNode.rate = 1.0
        mixerNode.outputVolume = 1.0
        
        // Restart engine
        do {
            try audioEngine.start()
        } catch {
            print("Failed to restart audio engine: \(error)")
        }
    }
    
    func startRecording() {
        // Stop any ongoing playback and reset
        resetAudioEngine()
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("recording.wav")
            
            // Delete existing recording if present
            if FileManager.default.fileExists(atPath: audioFilename.path) {
                try FileManager.default.removeItem(at: audioFilename)
            }
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            recorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            recorder?.record()
            
        } catch {
            print("Recording error: \(error)")
        }
    }
    
    func stopRecording() {
        recorder?.stop()
        recorder = nil
        
        // Load the new recording
        if let audioFileURL = getRecordingURL() {
            do {
                audioFile = try AVAudioFile(forReading: audioFileURL)
            } catch {
                print("Error loading recorded audio file: \(error)")
            }
        }
    }
    
    private func getRecordingURL() -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("recording.wav")
    }
    
    func playNormal() {
        guard let audioFile = audioFile else {
            print("No audio file available")
            return
        }
        
        resetAudioEngine()
        
        playerNode.scheduleFile(audioFile, at: nil)
        playerNode.play()
    }
    
    func playWithTinnitus() {
        guard let audioFile = audioFile else {
            print("No audio file available")
            return
        }
        
        resetAudioEngine()
        
        // Calculate the duration from the audio file
        let audioFormat = audioFile.processingFormat
        let audioFrameCount = UInt64(audioFile.length)
        let audioDuration = Double(audioFrameCount) / audioFormat.sampleRate
        
        // Retrieve volume level from UserDefaults with enhanced scaling
        let volume = UserDefaults.standard.double(forKey: "audioVolume")
        let adjustedVolume = pow(Float(volume > 0 ? volume : 0.1), 2) * 5.0

        // Generate high-pitched tinnitus sound matching the recording duration
        let sampleRate: Double = audioFormat.sampleRate
        let frequency: Double = 5000
        
        let tinnitus_format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)
        let frameCount = AVAudioFrameCount(sampleRate * audioDuration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: tinnitus_format!, frameCapacity: frameCount) else {
            print("Failed to create audio buffer")
            return
        }
        
        buffer.frameLength = buffer.frameCapacity
        
        // Generate tinnitus waveform with smooth amplitude modulation
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            
            // Add subtle amplitude modulation for more realistic tinnitus simulation
            let modulationFrequency: Double = 2.0
            let modulationDepth: Double = 0.1
            let modulation = 1.0 + modulationDepth * sin(2.0 * .pi * modulationFrequency * time)
            
            let value = sin(2.0 * .pi * frequency * time) * modulation
            
            // Apply the adjusted volume with smooth fade-in
            let fadeInDuration = min(0.1, audioDuration * 0.1) // 100ms or 10% of duration
            let fadeInMultiplier = min(time / fadeInDuration, 1.0)
            
            let finalValue = Float(value) * adjustedVolume * Float(fadeInMultiplier)
            
            // Write to both channels
            buffer.floatChannelData!.pointee[frame] = finalValue
            buffer.floatChannelData!.advanced(by: 1).pointee[frame] = finalValue
        }
        
        // Schedule both the original audio and tinnitus buffer
        playerNode.scheduleFile(audioFile, at: nil)
        tinnitusSoundNode.scheduleBuffer(buffer, at: nil, options: .loops)
        
        // Ensure synchronized playback
        playerNode.prepare(withFrameCount: frameCount)
        tinnitusSoundNode.prepare(withFrameCount: frameCount)
        
        playerNode.play()
        tinnitusSoundNode.play()
        
        // Schedule automatic stop after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + audioDuration) { [weak self] in
            self?.stop()
        }
    }

    // Add this method to ensure proper cleanup
    func stop() {
        playerNode.stop()
        tinnitusSoundNode.stop()
    }
    func playWithSuddenLoss() {
        guard let audioFile = audioFile else { return }
        
        resetAudioEngine()
        
        do {
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                         frameCapacity: AVAudioFrameCount(audioFile.length))!
            try audioFile.read(into: buffer)
            
            let numberOfDrops = 10
            let dropDuration = 0.2
            let sampleRate = audioFile.processingFormat.sampleRate
            let dropSamples = Int(dropDuration * sampleRate)
            
            for _ in 0..<numberOfDrops {
                let startSample = Int.random(in: 0..<Int(buffer.frameLength) - dropSamples)
                for sample in startSample..<(startSample + dropSamples) {
                    buffer.floatChannelData!.pointee[sample] = 0
                    buffer.floatChannelData!.advanced(by: 1).pointee[sample] = 0
                }
            }
            
            playerNode.scheduleBuffer(buffer, at: nil)
            playerNode.play()
        } catch {
            print("Error processing audio: \(error)")
        }
    }
    
    func playWithPresbycusis() {
        guard let audioFile = audioFile else { return }
        
        resetAudioEngine()
        
        effectNode.pitch = -400
        effectNode.rate = 0.9
        mixerNode.outputVolume = 0.3
        
        playerNode.scheduleFile(audioFile, at: nil)
        playerNode.play()
    }
}
