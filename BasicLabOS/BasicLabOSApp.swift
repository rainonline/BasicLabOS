import SwiftUI

@main
struct BasicLabOSApp: App {
    @State private var authStore = AuthSessionStore(authService: AuthService())

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authStore)
        }
    }
}
