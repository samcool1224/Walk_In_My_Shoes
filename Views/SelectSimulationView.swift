//
//  SelectSimulationView.swift
//  Walk In My Shoes
//
//  Created by Samaksh Bhargav on 2/23/25.
//

import SwiftUI
@available(iOS 17, *)
struct SelectSimulationView: View {
    @State private var selectedPage = 0
    let pages = ["visual", "audio"]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Select Simulation")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(15)
                    .padding(.top, 50)
                Text("Mode")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(3)
                    .padding(.top, 5)
                Spacer()
                
                // Refined TabView without default styling
                TabView(selection: $selectedPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        NavigationLink(
                            destination: destination(for: index),
                            label: {
                                Image(UIImage(names:pages[index], in .module, with : nil))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(.horizontal, 0)
                                    // Remove default styling
                                    .background(Color.clear)
                                    .border(.white, width: 4)
                            }
                        )
                        .buttonStyle(PlainButtonStyle()) // Remove button styling
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: UIScreen.main.bounds.height * 0.6)
                
                Spacer()
                
                // Enhanced navigation controls
                HStack {
                    Button(action: { withAnimation { selectedPage = max(selectedPage - 1, 0) } }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.7))
                            )
                    }
                    .padding(.leading, 20)
                    .opacity(selectedPage == 0 ? 0.5 : 1)
                    .disabled(selectedPage == 0)

                    Spacer()

                    Button(action: { withAnimation { selectedPage = min(selectedPage + 1, pages.count - 1) } }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(Color.black).opacity(0.7))
                    }
                    .padding(.trailing, 20)
                    .opacity(selectedPage == pages.count - 1 ? 0.5 : 1)
                    .disabled(selectedPage == pages.count - 1)
                }
                .padding(.vertical, 30)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func destination(for index: Int) -> some View {
        if index == 0 {
           VisionView()
        } else {
            AudioSimulationView()
        }
    }
}

