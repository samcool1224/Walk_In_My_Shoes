//
//  SettingsView.swift
//  Walk In My Shoes
//
//  Created by Samaksh Bhargav on 2/24/25.
//

import SwiftUI
@available(iOS 13, *)
struct SettingsView: View {
    @AppStorage("uiTheme") private var uiTheme: Int = 0
    @AppStorage("fontSize") private var fontSize: Double = 20
    @AppStorage("hapticIntensity") private var hapticIntensity: Double = 1.0
    @AppStorage("audioVolume") private var audioVolume: Double = 1.0
    @AppStorage("simulationDifficulty") private var simulationDifficulty: Int = 1
    @AppStorage("accessibilityMode") private var accessibilityMode: Bool = false
    @AppStorage("showGuidance") private var showGuidance: Bool = true
    @AppStorage("colorblindAssist") private var colorblindAssist: Bool = false
    @State private var showingVolumeWarning = false
    
    @Environment(\.colorScheme) var systemColorScheme
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 25) {
                    headerSection
                    audioSection
                    feedbackSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(uiTheme == 0 ? .light : .dark)
    }
    
    private var headerSection: some View {
        Text("Settings")
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [.primary, .primary.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
    
    private var appearanceSection: some View {
        SettingsSectionView(title: "Appearance") {
            Picker("Theme", selection: $uiTheme) {
                Text("Light").tag(1)
                Text("Dark").tag(2)
                Text("System").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            VStack(alignment: .leading) {
                Text("Font Size: \(Int(fontSize))")
                Slider(value: $fontSize, in: 16...30, step: 1)
            }
        }
    }
    
    private var audioSection: some View {
        SettingsSectionView(title: "Audio Simulation") {
            VStack(alignment: .leading) {
                Text("Volume: \(Int(audioVolume * 100))%")
                Slider(value: $audioVolume)
                    .onChange(of: audioVolume) { oldValue, newValue in
                        if newValue > 0.49 && !showingVolumeWarning {
                            showingVolumeWarning = true
                        }
                    }
                if audioVolume > 0.49 {
                    Text("Warning: High levels of volume at high frequencies could cause damage. Proceed only if necessary.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            }
        }
    }




    private func handleVolumeChange(_ newValue: Double) {
        if newValue > 0.49 && !showingVolumeWarning {
            showingVolumeWarning = true
        }
    }

    
    private var feedbackSection: some View {
        SettingsSectionView(title: "Feedback") {
            VStack(alignment: .leading) {
                Text("Haptic Intensity: \(Int(hapticIntensity * 100))%")
                Slider(value: $hapticIntensity)
            }
        }
    }
}
@available(iOS 13, *)
struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            content
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(radius: 2)
                )
        }
    }
}
