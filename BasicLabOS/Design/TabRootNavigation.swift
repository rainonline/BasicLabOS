import SwiftUI

extension View {
    /// iOS 26 tab root: large title inside the Liquid Glass toolbar, system scroll-edge effects.
    func tabRootNavigationStyle() -> some View {
        toolbarTitleDisplayMode(.inlineLarge)
    }
}
