//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 29.09.2022.
//

import Foundation
import SwiftUI

public struct SheetWrapperView<Content: View, PrefContent: View>: View {
    init(prefs: Preferences<PrefContent>, content: Content) {
        self.prefs = prefs
        self.content = content
    }
    
    private var prefs: Preferences<PrefContent>
    private let content: Content
    
    public var body: some View {
        ZStack {
            NativePartialSheetView(prefs)
            content
        }
    }
}

public extension SheetWrapperView {
    func sheetColor(_ color: UIColor) -> SheetWrapperView {
        prefs.sheetColor = color
        return self
    }
    
    func sheetShadow(
        color: UIColor? = nil,
        offset: CGSize? = nil,
        radius: CGFloat? = nil
    ) -> SheetWrapperView {
        prefs.sheetShadowColor = color
        prefs.sheetShadowOffset = offset
        prefs.sheetShadowRadius = radius
        return self
    }
    
    func interactiveDismissDisabled(
        _ isDisabled: Bool = true,
        onWillDismiss: (() -> Void)? = nil,
        onDidDismiss: (() -> Void)? = nil
    ) -> SheetWrapperView {
        prefs.interactiveDismissDisabled = isDisabled
        prefs.onDidDismiss = onDidDismiss
        prefs.onWillDismiss = onWillDismiss
        return self
    }

    func presentationDetents(_ detents: Set<Detent>, selection: Binding<Detent>? = nil) -> SheetWrapperView {
        prefs.detents = detents
        if let selection = selection {
            prefs.selectedDetent = selection
        }
        return self
    }
    
    func cornerRadius(_ radius: CGFloat?) -> SheetWrapperView {
        prefs.preferredCornerRadius = radius
        return self
    }
    
    func presentationDragIndicator(_ visibility: Visibility) -> SheetWrapperView {
        prefs.presentationDragIndicator = visibility
        return self
    }
    
    func edgeAttachedInCompactHeight(_ attached: Bool = true) -> SheetWrapperView {
        prefs.prefersEdgeAttachedInCompactHeight = attached
        return self
    }
    
    func scrollingExpandsWhenScrolledToEdge(_ expands: Bool = true) -> SheetWrapperView {
        prefs.prefersScrollingExpandsWhenScrolledToEdge = expands
        return self
    }
    
    func widthFollowsPreferredContentSizeWhenEdgeAttached(_ follows: Bool = true) -> SheetWrapperView {
        prefs.widthFollowsPreferredContentSizeWhenEdgeAttached = follows
        return self
    }
    
    func largestUndimmedDetent(_ detent: Detent?) -> SheetWrapperView {
        prefs.largestUndimmedDetent = detent
        return self
    }
}
