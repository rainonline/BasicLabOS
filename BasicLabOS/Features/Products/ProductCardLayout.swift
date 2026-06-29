import SwiftUI

enum ProductCardLayout {
    static let compactColumnCount = 2
    static let regularMinimumColumnWidth: CGFloat = 200
    static let gridSpacing: CGFloat = 14
    static let rowSpacing: CGFloat = 14

    static func columns(for horizontalSizeClass: UserInterfaceSizeClass?) -> [GridItem] {
        if horizontalSizeClass == .regular {
            return [GridItem(.adaptive(minimum: regularMinimumColumnWidth), spacing: gridSpacing)]
        }

        return Array(
            repeating: GridItem(.flexible(), spacing: gridSpacing, alignment: .top),
            count: compactColumnCount
        )
    }

    static func horizontalPadding(for horizontalSizeClass: UserInterfaceSizeClass?) -> CGFloat {
        horizontalSizeClass == .regular ? 24 : 16
    }

    static let skeletonHeight: CGFloat = 236
}
