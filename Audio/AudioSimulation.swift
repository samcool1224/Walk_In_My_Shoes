//
//  AudioSimulation.swift
//  Walk In My Shoes
//
//  Created by Samaksh Bhargav on 2/24/25.
//
import SwiftUI
@available(iOS 13, *)
@available(iOS 17, *)
struct AudioSimulationView: View {
    let chapters: [AudioChapter] = [
        AudioChapter(
            title: "Chapter 1: Normal Hearing",
            narrative: "Begin your journey with pristine audio clarity. This recording creates our baseline, capturing the full spectrum of sound as nature intended - every whisper, every subtle detail in perfect fidelity.",
            warning:"",
            simulationType: .normal
        ),
        AudioChapter(
            title: "Chapter 2: Sudden Hearing Loss",
            narrative: "Experience the unsettling reality of intermittent hearing loss. Notice how sounds fade unexpectedly, creating moments of silence that can be both confusing and disorienting.",
            warning:"",
            simulationType: .suddenLoss
        ),
        AudioChapter(
            title: "Chapter 3: Presbycusis",
            narrative: "Step into the world of age-related hearing loss. High frequencies become distant memories, while conversations transform into a challenge of understanding through muffled tones.",
            warning:"",
            simulationType: .presbycusis
        ),
        AudioChapter(
            title: "Chapter 4: Tinnitus",
            narrative: "Discover the persistent companion of millions - the eternal whistle of tinnitus. This simulation reveals how a constant internal sound can overlay every moment of daily life.",
            warning: "⚠️ High-pitched frequencies can lead to lasting ear damage after frequent or prolonged use. Please exercise caution.",
            simulationType: .tinnitus
        )
    ]
    @available(iOS 13, *)
    let brightYellow = Color(hex: "fdff8f")
    @State private var currentChapterIndex = 0
    @State private var isRecording = false
    @State private var hasRecording = false
    @available(iOS 17, *)
    @StateObject private var audioManager = AudioManager.shared
    @available(iOS 13, *)
    @State private var cardOffset: CGFloat = 1000
    @State private var cardOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Matching gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1a2a6c"),
                    Color(hex: "b21f1f"),
                    Color(hex: "fdbb2d")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                // Enhanced Chapter Title
                Text(chapters[currentChapterIndex].title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 10)
                .padding(.top, 40)
                .padding(.horizontal)
                
                // Narrative Section
                ScrollView {
                    GlassCard {
                        VStack {
                            Text(chapters[currentChapterIndex].narrative)
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            if chapters[currentChapterIndex].simulationType == .tinnitus {
                                Text(chapters[currentChapterIndex].warning)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(brightYellow)
                                    .multilineTextAlignment(.center)
                                    .padding([.horizontal, .bottom])
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                @available(iOS 17, *)
                GlassCard {
                    VStack(spacing: 20) {
                        if !hasRecording {
                            // Recording Button
                            AudioControlButton(
                                icon: isRecording ? "stop.circle.fill" : "record.circle",
                                text: isRecording ? "Stop Recording" : "Start Recording",
                                colors: isRecording ? [.red, .pink] : [.blue, .indigo],
                                action: toggleRecording
                            )
                        } else {
                            // Playback Controls
                            VStack(spacing: 15) {
                                AudioControlButton(
                                    icon: "play.circle.fill",
                                    text: "Play Simulation",
                                    colors: [.green, .teal],
                                    action: playSimulation
                                )
                                
                                AudioControlButton(
                                    icon: "arrow.clockwise.circle.fill",
                                    text: "New Recording",
                                    colors: [.orange, .red],
                                    action: resetRecording
                                )
                            }
                        }
                        // Chapter Navigation
                        HStack(spacing: 20) {
                            NavigationButton(
                                icon: "chevron.left.circle.fill",
                                colors: [.gray.opacity(0.7), .gray.opacity(0.5)],
                                action: previousChapter,
                                isDisabled: currentChapterIndex == 0
                            )
                            
                            NavigationButton(
                                icon: "chevron.right.circle.fill",
                                colors: [.blue, .indigo],
                                action: nextChapter,
                                isDisabled: currentChapterIndex == chapters.count - 1
                            )
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(false)
        @available(iOS 14, *)
        .navigationBarTitleDisplayMode(.inline)
        @available(iOS 13, *)
        .onAppear {
            withAnimation(.spring()) {
                cardOffset = 0
                cardOpacity = 1
            }
        }
    }
    
    // Existing helper functions remain the same
    private func toggleRecording() {
        withAnimation(.spring()) {
            if !isRecording {
                audioManager.startRecording()
            } else {
                audioManager.stopRecording()
                hasRecording = true
            }
            isRecording.toggle()
        }
    }
    
    private func playSimulation() {
        audioManager.playSimulation(for: chapters[currentChapterIndex].simulationType)
    }
    
    private func resetRecording() {
        withAnimation(.spring()) {
            hasRecording = false
            audioManager.resetRecording()
        }
    }
    
    private func nextChapter() {
        withAnimation(.spring()) {
            if currentChapterIndex < chapters.count - 1 {
                currentChapterIndex += 1
                audioManager.stopAudio()
            }
        }
    }
    
    private func previousChapter() {
        withAnimation(.spring()) {
            if currentChapterIndex > 0 {
                currentChapterIndex -= 1
                audioManager.stopAudio()
            }
        }
    }
}
