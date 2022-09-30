//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 29.09.2022.
//

import Foundation
import SwiftUI

public struct UnwrapView<T, Content: View>: View {
    @Binding var value: T?
    var content: ((T) -> Content)
    
    public var body: some View {
        if let value = value {
            content(value)
        }
    }
}

public extension View {
    func sheet<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> SheetWrapperView<Self, Content> {
        let prefs = Preferences(
            isPresented: isPresented,
            onDismiss: onDismiss,
            content: content
        )
        return SheetWrapperView(prefs: prefs, content: self)
    }
    
    func sheet<Content: View>(
        selectedDetent: Binding<Detent?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Detent) -> Content
    ) -> SheetWrapperView<Self, UnwrapView<Detent, Content>> {
        let prefs = Preferences(
            isPresented: .init(
                get: { selectedDetent.wrappedValue != nil },
                set: { isPresented in
                    if !isPresented, selectedDetent.wrappedValue != nil {
                        selectedDetent.wrappedValue = nil
                    }
                }
            ),
            onDismiss: onDismiss,
            selectedDetent: .init(
                get: { selectedDetent.wrappedValue ?? .large },
                set: { detent in
                    selectedDetent.wrappedValue = detent
                }
            ),
            content: {
                UnwrapView(value: selectedDetent, content: content)
            }
        )
        return SheetWrapperView(prefs: prefs, content: self)
    }
    
    func sheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> SheetWrapperView<Self, UnwrapView<Item, Content>> {
        let prefs = Preferences(
            isPresented: .init(
                get: { item.wrappedValue != nil },
                set: { isPresented in
                    if !isPresented, item.wrappedValue != nil {
                        item.wrappedValue = nil
                    }
                }
            ),
            onDismiss: onDismiss,
            content: {
                UnwrapView(value: item, content: content)
            }
        )
        return SheetWrapperView(prefs: prefs, content: self)
    }
}
