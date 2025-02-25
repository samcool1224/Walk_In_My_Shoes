// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
@available(iOS 17, *)

struct WalkInMyShoesApp: App {
    @AppStorage("uiTheme") private var uiTheme: Int = 1

    var body: some SwiftUI.Scene {
        let theme: ColorScheme? = uiTheme == 2 ? .dark : (uiTheme == 1 ? .light : nil)
        
        return WindowGroup {
            NavigationView {
                ContentView()
                    .preferredColorScheme(theme)
            }
        }
    }
}
