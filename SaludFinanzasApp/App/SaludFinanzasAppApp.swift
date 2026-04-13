import SwiftUI

@main
struct SaludFinanzasAppApp: App {
    @State private var env = AppEnvironment()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(env)
        }
    }
}


