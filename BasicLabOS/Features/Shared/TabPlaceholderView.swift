import SwiftUI

struct TabPlaceholderView: View {
    let title: String
    let systemImage: String

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: systemImage,
            description: Text("此页面即将推出。")
        )
        .navigationTitle(title)
        .tabRootNavigationStyle()
    }
}
