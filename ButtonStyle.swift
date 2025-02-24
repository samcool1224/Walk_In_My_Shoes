//
//  ButtonStyle.swift
//  Walk In My Shoes
//
//  Created by Samaksh Bhargav on 2/23/25.
//
import SwiftUI
@available(iOS 13, *)

public struct PrimaryButtonStyle: ButtonStyle {
    let colors: [Color]
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .foregroundColor(.white)
            .font(.system(size: 18, weight: .bold, design: .rounded))
    }
}
