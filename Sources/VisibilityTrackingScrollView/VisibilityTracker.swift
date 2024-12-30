// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/07/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public enum VisibilityChange {
    case hidden(_ threshold: CGFloat)
    case shown(_ threshold: CGFloat)
}

public class VisibilityTracker<ID: Hashable>: ObservableObject {
    /// The global bounds of the container view.
    public var containerBounds: CGRect
    
    /// Dictionary containing the offset of every visible view.
    public var visibleViews: [ID:CGFloat]
    
    private var visibilityByThresholds: [ID:[CGFloat]]
    
    /// Visible threshold offset
    private let thresholds: [CGFloat]
    
    /// Ids of the visible views, sorted by offset.
    /// The first item is the top view, the last one, the bottom view.
    public var sortedViewIDs: [ID]
    
    /// Action to perform when a view becomes visible or is hidden.
    public var action: Action
    
    /// The id of the top visible view.
    public var topVisibleView: ID? { sortedViewIDs.first }
    
    /// The id of the bottom visible view.
    public var bottomVisibleView: ID? { sortedViewIDs.last }

    /// Action callback signature.
    public typealias Action = (ID, VisibilityChange, VisibilityTracker<ID>) -> ()

    public init(thresholds: [CGFloat], action: @escaping Action) {
        self.containerBounds = .zero
        self.visibleViews = [:]
        self.sortedViewIDs = []
        self.action = action
        self.thresholds = thresholds
        self.visibilityByThresholds = [:]
    }
    
    public func reportContainerBounds(_ bounds: CGRect) {
        containerBounds = bounds
    }
    
    public func reportContentBounds(_ bounds: CGRect, id: ID) {
        let topLeft = bounds.origin
        let size = bounds.size
        let bottomRight = CGPoint(x: topLeft.x + size.width, y: topLeft.y + size.height)
        let isVisible = containerBounds.contains(topLeft) || containerBounds.contains(bottomRight)

        let visibleThreshold = threshold(bounds)

        if isVisible {
            var visibleThresholds = visibilityByThresholds[id] ?? []
            visibleViews[id] = bounds.origin.y - containerBounds.origin.y
            sortViews()
            thresholds.forEach { threshold in
                if visibleThreshold >= threshold {
                    if !visibleThresholds.contains(threshold) {
                        visibleThresholds.append(threshold)
                        visibilityByThresholds[id] = visibleThresholds
                        action(id, .shown(threshold), self)
                    }
                } else {
                    if visibleThresholds.contains(threshold) {
                        visibleThresholds.removeAll { $0 == threshold }
                        visibilityByThresholds[id] = visibleThresholds
                        action(id, .hidden(threshold), self)
                    }
                }
            }
        } else {
            let wasVisible = visibleViews[id] != nil
            if wasVisible {
                visibleViews.removeValue(forKey: id)
                visibilityByThresholds[id] = []
                sortViews()
                action(id, .hidden(0), self)
            }
        }
    }
    
    private func threshold(_ bounds: CGRect) -> CGFloat {
        let intersectionRect = containerBounds.intersection(bounds)
        
        let originalArea = bounds.width * bounds.height
        let intersectionArea = intersectionRect.width * intersectionRect.height
        
        return intersectionArea / originalArea
    }
    
    func sortViews() {
        let sortedPairs = visibleViews.sorted(by: { $0.1 < $1.1 })
        sortedViewIDs = sortedPairs.map { $0.0 }
    }
}

