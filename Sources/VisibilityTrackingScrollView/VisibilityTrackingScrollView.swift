// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public struct VisibilityTrackingScrollView<Content, ID>: View where Content: View, ID: Hashable {
    @ViewBuilder let content: Content
    let axes: Axis.Set
    @State var visibilityTracker: VisibilityTracker<ID>
    
    public init(axes: Axis.Set = .vertical, action: @escaping VisibilityTracker<ID>.Action, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._visibilityTracker = .init(initialValue: VisibilityTracker<ID>(thresholds: [0.1, 0.5], action: action))
        self.axes = axes
    }
    
    public var body: some View {
        ScrollView(axes) {
            content
                .environmentObject(visibilityTracker)
        }
        .background(
            GeometryReader { proxy in
                report(proxy: proxy)
            }
        )
    }
    
    func report(proxy: GeometryProxy) -> Color {
        visibilityTracker.reportContainerBounds(proxy.frame(in: .global))
        return Color.clear
    }
    
}
