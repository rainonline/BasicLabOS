import SwiftUI

struct RootView: View {
    @Environment(AuthSessionStore.self) private var authStore

    var body: some View {
        Group {
            if authStore.isRestoring {
                ProgressView("正在恢复登录…")
            } else if authStore.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .task {
            await authStore.restore()
        }
    }
}
