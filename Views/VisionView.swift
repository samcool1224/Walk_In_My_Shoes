//
//  VisionView.swift
//  Walk In My Shoes
//
//  Created by Samaksh Bhargav on 2/24/25.
//
import SwiftUI
import RealityKit
import ARKit
import Combine
@available(iOS 14, *)
struct VisionView: View {
    // Expanded stages for roughly 3 minutes of exploration (Complaint 4)
    let stages: [Stage] = [
        Stage(narrative: "Chapter 1: Normal Vision\nEvery detail is sharp and vibrant.", impairment: .none, challengeQuestion: "What defines normal vision?", options: ["Sharp details", "Blurred shapes", "Dark vision", "Tunnel vision"], correctAnswer: "Sharp details"),
        Stage(narrative: "Chapter 2: Cataract\nYour vision becomes clouded and hazy.", impairment: .cataract, challengeQuestion: "Which symptom is typical for cataracts?", options: ["Clear vision", "Cloudy vision", "Double vision", "Color blindness"], correctAnswer: "Cloudy vision"),
        Stage(narrative: "Chapter 3: Glaucoma\nYour peripheral vision gradually diminishes.", impairment: .glaucoma, challengeQuestion: "Glaucoma affects which part of vision?", options: ["Central", "Peripheral", "Color", "Depth"], correctAnswer: "Peripheral"),
        Stage(narrative: "Chapter 4: Tunnel Vision\nOnly a small central area remains visible.", impairment: .tunnelVision, challengeQuestion: "Tunnel vision affects which aspect?", options: ["Peripheral", "Central", "Color", "Brightness"], correctAnswer: "Peripheral"),
        Stage(narrative: "Chapter 5: Macular Degeneration\nA dark spot forms at the center of vision.", impairment: .macularDegeneration, challengeQuestion: "What is a hallmark of macular degeneration?", options: ["Blurred peripheral vision", "Central scotoma", "Double vision", "Increased brightness"], correctAnswer: "Central scotoma"),
    ]
    
    @State private var currentStageIndex = 0
    @State private var showARSimulation = false
    @State private var showQuiz = false
    @State private var challengeAnswered = false
    @State private var challengeCorrect = false
    @State private var showRetryAlert = false
    // New animation states
    @State private var cardOffset: CGFloat = 1000
    @State private var cardOpacity: Double = 0
    @State private var buttonScale: CGFloat = 1
    @State private var showConfetti = false

    func triggerConfetti() {
        showConfetti = true  // Activate confetti
        print("trying")
        Task {
            print("trying")
            try? await Task.sleep(nanoseconds: 50_000_000)
            await MainActor.run { showConfetti = false }  // Safely update UI state
        }
    }

        var body: some View {
            ZStack {
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
                
                if showARSimulation {
                    // AR Experience
                    ZStack {
                        ARViewContainer(selectedImpairment: stages[currentStageIndex].impairment)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            Spacer()
                            // Floating info card
                            GlassCard {
                                VStack(spacing: 15) {
                                    Text(stages[currentStageIndex].narrative)
                                        .font(.system(size: 20, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            showARSimulation = false
                                            showQuiz = true
                                        }
                                    }) {
                                        HStack {
                                            Text("Take Quiz")
                                            Image(systemName: "arrow.right.circle.fill")
                                        }
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(
                                            Capsule()
                                                .fill(LinearGradient(
                                                    colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ))
                                        )
                                    }
                                }
                                .padding()
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 50)
                        }
                    }
                } else if showQuiz {
                    // Quiz View
                    VStack {
                        Spacer()
                        
                        GlassCard {
                            VStack(spacing: 20) {
                                Text(stages[currentStageIndex].challengeQuestion)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                ForEach(stages[currentStageIndex].options.indices, id: \.self) { index in
                                    QuizButton(
                                        text: stages[currentStageIndex].options[index],
                                        isSelected: challengeAnswered && stages[currentStageIndex].options[index] == stages[currentStageIndex].correctAnswer,
                                        action: {
                                            answerTapped(stages[currentStageIndex].options[index])
                                            
                                            Task {
                                                print("here")
                                                if challengeAnswered && challengeCorrect {
                                                    print("Here")
                                                    triggerConfetti()
                                                }
                                            }
                                        }
                                    )
                                }
                            
                                
                                if challengeAnswered {
                                    if challengeCorrect {
                                        NextStageButton {
                                            proceedToNextStage()
                                        }
                                    } else {
                                        RetryButton {
                                            challengeAnswered = false
                                            showARSimulation = true
                                            showQuiz = false
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .padding()
                        
                        Spacer()
                    }
                    ConfettiView(isVisible: $showConfetti)
                        .allowsHitTesting(false)
                        .ignoresSafeArea()
                } else {
                    // Initial Stage View
                    VStack {
                        Text(stages[currentStageIndex].narrative)
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black.opacity(0.3))
                            )
                            .padding()
                        
                        Spacer()
                        
                        StartSimulationButton {
                            withAnimation(.spring()) {
                                showARSimulation = true
                            }
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        
        // Helper functions remain the same, but with enhanced feedback
        private func answerTapped(_ option: String) {
            withAnimation(.spring()) {
                if option == stages[currentStageIndex].correctAnswer {
                    challengeCorrect = true
                    HapticManager.shared.triggerHaptic()
                } else {
                    challengeCorrect = false
                    HapticManager.shared.triggerHaptic()
                }
                challengeAnswered = true
            }
        }
        
        private func proceedToNextStage() {
            withAnimation(.spring()) {
                challengeAnswered = false
                challengeCorrect = false
                showQuiz = false
                currentStageIndex = (currentStageIndex + 1) % stages.count
                showARSimulation = true
                HapticManager.shared.triggerHaptic()
            }
        }
    }

    // Custom UI Components
    struct GlassCard<Content: View>: View {
        let content: Content
        
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            content
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.1))
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white)
                                .opacity(0.08)
                                .blur(radius: 10)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }

    struct QuizButton: View {
        let text: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(text)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                isSelected ?
                                LinearGradient(colors: [Color.green.opacity(0.7), Color.blue.opacity(0.7)], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color.purple.opacity(0.5), Color.blue.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
                            )
                    )
                    .shadow(radius: 5)
            }
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(), value: isSelected)
        }
    }

    struct StartSimulationButton: View {
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text("Begin Experience")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10)
            }
        }
    }

    struct NextStageButton: View {
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text("Next Chapter")
                    Image(systemName: "arrow.right.circle.fill")
                }
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.green, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(radius: 5)
            }
        }
    }

    struct RetryButton: View {
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text("Review Again")
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                }
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(radius: 5)
            }
        }
    }

    // Helper extension for hex colors
    extension Color {
        init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3:
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6:
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8:
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0)
            }
            self.init(
                .sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue:  Double(b) / 255,
                opacity: Double(a) / 255
            )
        }
    }
