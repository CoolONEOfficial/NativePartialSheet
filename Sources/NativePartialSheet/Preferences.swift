//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 29.09.2022.
//

import Foundation
import SwiftUI

final class Preferences<Content: View> {
    init(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)?,
        selectedDetent: Binding<Detent> = .constant(.large),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isPresented = isPresented
        self.content = content
        self.selectedDetent = selectedDetent
        self.onDidDismiss = onDismiss
    }
    
    var content: () -> Content
    var isPresented: Binding<Bool>
    var selectedDetent: Binding<Detent>
    var detents: Set<Detent> = [.large]
    var preferredCornerRadius: CGFloat?
    var presentationDragIndicator: Visibility = .automatic
    var prefersEdgeAttachedInCompactHeight = false
    var prefersScrollingExpandsWhenScrolledToEdge = true
    var widthFollowsPreferredContentSizeWhenEdgeAttached = false
    var largestUndimmedDetent: Detent?
    var interactiveDismissDisabled = false
    var onWillDismiss: (() -> Void)?
    var onDidDismiss: (() -> Void)?
    var sheetShadowColor: UIColor?
    var sheetShadowOffset: CGSize?
    var sheetShadowRadius: CGFloat?
    var sheetColor: UIColor = .systemBackground
}
