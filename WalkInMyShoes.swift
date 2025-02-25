// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
@available(iOS 17, *)
public struct WalkInMyShoesApp: View {
    @AppStorage("uiTheme") private var uiTheme: Int = 1
    
    public init() {}
    
    public var body: some View {
        let theme: ColorScheme? = uiTheme == 2 ? .dark : (uiTheme == 1 ? .light : nil)
        
        NavigationView {
            ContentView()  // You can call any view here
                .preferredColorScheme(theme)
        }
    }
}

