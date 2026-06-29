import SwiftUI

enum CatalogSurfaceStyle {
  /// 列表画布底色，对齐 Settings / App Store 等系统分组界面。
  static let canvas = Color(.systemGroupedBackground)
  /// 卡片 / 单元格抬升面。
  static let card = Color(.secondarySystemGroupedBackground)
}

extension View {
  /// 商品目录等网格列表：隐藏 ScrollView 默认底，铺分组灰底。
  func catalogCanvasBackground() -> some View {
    scrollContentBackground(.hidden)
      .background(CatalogSurfaceStyle.canvas)
  }
}
