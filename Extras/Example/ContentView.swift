// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import VisibilityTrackingScrollView

public extension Color {
    
    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }
}

struct ContentView: View {
    var body: some View {
        VisibilityTrackingScrollView(axes: .horizontal, action: handleVisibilityChanged) {
            LazyHStack {
                ForEach(0..<100, id: \.self) { item in
                    Text("\(item)")
                        .frame(width: 100, height: CGFloat.random(in: 20...100))
                        .background(Color.random())
                        .trackVisibility(id: "\(item)")
                }
            }
        }
        .border(.red)
    }
    
    func handleVisibilityChanged(_ id: String, change: VisibilityChange, tracker: VisibilityTracker<String>) {
        switch change {
        case .shown(let threshold):
            print("\(id) shown -- Threshold: \(threshold)")
        case .hidden(let threshold):
            print("\(id) hidden -- Threshold: \(threshold)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
