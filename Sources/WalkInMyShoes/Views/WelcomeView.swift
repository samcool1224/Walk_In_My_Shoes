//
//  WelcomeView.swift
//  Walk In My Shoes
//
//  Created by Samaksh Bhargav on 2/23/25.
//
import SwiftUI

struct WelcomeView: View {
    @AppStorage("uiTheme") private var uiTheme: Int = 1
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        // Set the theme based on user preference or default to system appearance (colorScheme)
        let theme: ColorScheme = uiTheme == 2 ? .dark : (uiTheme == 1 ? .light : colorScheme)
        
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                Text("Walk in My Shoes")
                    .font(.custom("Baloo2-Bold", size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.mint, Color.teal, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: 6)
                    .padding(.horizontal)
                    .padding(.top, 60)
                
                Text("Experience the challenges of sensory impairments through innovative simulations. Step into someone else's shoes and transform your perspective.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(theme == .dark ? .white : .black) // Apply color based on theme
                    .padding(20)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                NavigationLink(destination: SelectSimulationView()) {
                    Text("Select Simulation")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle(colors: [Color.blue, Color.purple]))
                .padding(.horizontal, 30)
                
                NavigationLink(destination: SettingsView()) {
                    Text("Settings")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle(colors: [Color.green, Color.teal]))
                .padding(.horizontal, 30)
                
                NavigationLink(destination: CreditsView()) {
                    Text("Credits")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle(colors: [Color.orange, Color.red]))
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
