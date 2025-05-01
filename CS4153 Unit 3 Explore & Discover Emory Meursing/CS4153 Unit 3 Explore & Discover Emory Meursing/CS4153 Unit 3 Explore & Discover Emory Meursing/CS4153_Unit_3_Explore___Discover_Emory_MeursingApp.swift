//___FILEHEADER___

import SwiftUI

@main
struct StorybookApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                VStack {
                    Spacer()
                    CharacterView()
                        .padding(.bottom, 50)
                }
            }
        }
    }
}
