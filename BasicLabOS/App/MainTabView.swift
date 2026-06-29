import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("商品", systemImage: "shippingbox") {
                NavigationStack {
                    ProductListView()
                }
            }
            Tab("发现", systemImage: "sparkles") {
                NavigationStack {
                    TabPlaceholderView(title: "发现", systemImage: "sparkles")
                }
            }
            Tab("我的", systemImage: "person.crop.circle") {
                NavigationStack {
                    TabPlaceholderView(title: "我的", systemImage: "person.crop.circle")
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
