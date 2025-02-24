//
//  CreditsView.swift
//  Walk In My Shoes
//
//  Created by Samaksh Bhargav on 2/24/25.
//
import SwiftUI
struct CreditsView: View {
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
                    teamSection
                    acknowledgementsSection
                    thanksSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light) // Use systemColorScheme if needed
    }

    private var headerSection: some View {
        Text("Credits")
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [.primary, .primary.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }

    private var teamSection: some View {
        SettingsSectionView(title: "Development Team") {
            VStack(alignment: .leading) {
                Text("Samaksh Bhargav - Lead Developer")

            }
        }
    }

    private var acknowledgementsSection: some View {
        SettingsSectionView(title: "Acknowledgements") {
            VStack(alignment: .leading) {
                Text("Special thanks to the Swift | Apple Developer Documentation and Swift.org for their invaluable contributions to teaching me Swift.")
                Text("Many thanks to all my friends who tested the app for their feedback and support, making sure the app runs smoothly.")
            }
        }
    }

    private var thanksSection: some View {
        SettingsSectionView(title: "Thanks") {
            VStack(alignment: .leading) {
                Text("I'd like to thank my familiy for their unwavering support.")
                Text("A huge thank you, our users.")
            }
        }
    }
}
