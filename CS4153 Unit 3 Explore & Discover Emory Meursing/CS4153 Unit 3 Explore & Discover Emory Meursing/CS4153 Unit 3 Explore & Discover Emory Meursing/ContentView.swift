import SwiftUI
import UIKit

struct StoryPage: Identifiable {
    let id = UUID()
    let imageName: String
    let text: String
}

struct ContentView: View {
    @State private var selectedPage: StoryPage?
    @Namespace private var animationNamespace
    @State private var isDarkMode = false

    let storyPages = [
        StoryPage(imageName: "page1", text: "Once upon a time..."),
        StoryPage(imageName: "page2", text: "In a faraway land..."),
        StoryPage(imageName: "page3", text: "They lived happily ever after.")
    ]

    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Toggle(isOn: $isDarkMode) {
                        Text("Dark Mode")
                            .foregroundColor(Color(.label))
                    }
                    .padding()

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(storyPages) { page in
                                ZStack {
                                    Image(page.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geometry.size.width / 2.2, height: 200)
                                        .clipped()
                                        .cornerRadius(15)
                                        .matchedGeometryEffect(id: page.id, in: animationNamespace)
                                        .onTapGesture {
                                            withAnimation(.easeInOut) {
                                                selectedPage = page
                                            }
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                    .blur(radius: selectedPage != nil ? 10 : 0)
                }

                if let selectedPage = selectedPage {
                    ZStack(alignment: .topTrailing) {
                        Color(.systemBackground)
                            .edgesIgnoringSafeArea(.all)

                        VStack {
                            Image(selectedPage.imageName)
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: selectedPage.id, in: animationNamespace)
                                .frame(maxWidth: .infinity)
                                .transition(.slide)
                                .padding()

                            Text(selectedPage.text)
                                .font(.title)
                                .foregroundColor(Color(.label))
                                .multilineTextAlignment(.center)
                                .padding()
                                .transition(.opacity)
                        }
                        .gesture(
                            DragGesture().onEnded { value in
                                if abs(value.translation.width) > 100 {
                                    withAnimation(.spring()) {
                                        self.selectedPage = nil
                                    }
                                }
                            }
                        )

                        Button(action: {
                            withAnimation(.spring()) {
                                self.selectedPage = nil
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.largeTitle)
                                .padding()
                                .foregroundColor(.secondary)
                        }
                    }
                    .transition(.scale)
                }
            }
            .environment(\.colorScheme, isDarkMode ? .dark : .light)
        }
    }
}

struct CharacterView: View {
    @State private var isBouncing = false
    @State private var dragOffset: CGSize = .zero
    @State private var characterScale: CGFloat = 1.0
    @State private var characterRotation: Angle = .zero

    var body: some View {
        Image("character")
            .resizable()
            .frame(width: 100, height: 100)
            .offset(y: isBouncing ? -20 : 0)
            .offset(dragOffset)
            .scaleEffect(characterScale)
            .rotationEffect(characterRotation)
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isBouncing)
            .onAppear {
                isBouncing = true
            }
            .gesture(
                SimultaneousGesture(
                    TapGesture().onEnded {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        print("Character tapped! Vibration triggered.")
                    },
                    SimultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) {
                                    dragOffset = .zero
                                }
                            },
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { scale in
                                    characterScale = scale
                                }
                                .onEnded { _ in
                                    withAnimation { characterScale = 1.0 }
                                },
                            RotationGesture()
                                .onChanged { angle in
                                    characterRotation = angle
                                }
                                .onEnded { _ in
                                    withAnimation { characterRotation = .zero }
                                }
                        )
                    )
                )
            )
    }
}
