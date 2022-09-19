import Foundation
import NativePartialSheetHelper
import UIKit
import SwiftUI

public enum Detent {
    case medium
    case large
    case custom(id: String = UUID().uuidString, constant: CGFloat)

    var system: UISheetPresentationController.Detent {
        switch self {
        case .medium:
            return .medium()

        case .large:
            return .large()

        case let .custom(id, constant):
            if #available(iOS 16.0, *) {
                return .custom(identifier: .init(rawValue: id), resolver: {_ in constant})
            } else {
                return ._detent(withIdentifier: id, constant: constant)
            }
        }
    }
}

private protocol Preferences {
    var detents: [Detent] { get }
    var preferredCornerRadius: CGFloat? { get }
    var prefersGrabberVisible: Bool { get }
    var prefersEdgeAttachedInCompactHeight: Bool { get }
    var prefersScrollingExpandsWhenScrolledToEdge: Bool { get }
    var widthFollowsPreferredContentSizeWhenEdgeAttached: Bool { get }
    var largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? { get }
    var selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier? { get }
}

public class NativePartialSheetController<Content>: UIHostingController<Content> where Content : View {
    fileprivate var prefs: Preferences?

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let presentation = sheetPresentationController,
           let prefs = prefs {
            presentation.detents = prefs.detents.map(\.system)
            presentation.prefersGrabberVisible = prefs.prefersGrabberVisible
            presentation.largestUndimmedDetentIdentifier = prefs.largestUndimmedDetentIdentifier
            presentation.preferredCornerRadius = prefs.preferredCornerRadius
            presentation.prefersEdgeAttachedInCompactHeight = prefs.prefersEdgeAttachedInCompactHeight
            presentation.prefersScrollingExpandsWhenScrolledToEdge = prefs.prefersScrollingExpandsWhenScrolledToEdge
            presentation.widthFollowsPreferredContentSizeWhenEdgeAttached = prefs.widthFollowsPreferredContentSizeWhenEdgeAttached
            presentation.selectedDetentIdentifier = prefs.selectedDetentIdentifier
        }
        isModalInPresentation = true
    }
}

public struct NativePartialSheet<Content>: Preferences, UIViewControllerRepresentable where Content : View {
    private let content: Content
    let detents: [Detent]
    let preferredCornerRadius: CGFloat?
    let prefersGrabberVisible: Bool
    let prefersEdgeAttachedInCompactHeight: Bool
    let prefersScrollingExpandsWhenScrolledToEdge: Bool
    let widthFollowsPreferredContentSizeWhenEdgeAttached: Bool
    let largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    let selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier?

    public init(
        detents: [Detent] = [.medium, .large],
        preferredCornerRadius: CGFloat? = nil,
        prefersGrabberVisible: Bool = false,
        prefersEdgeAttachedInCompactHeight: Bool = false,
        prefersScrollingExpandsWhenScrolledToEdge: Bool = true,
        widthFollowsPreferredContentSizeWhenEdgeAttached: Bool = false,
        largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = nil,
        selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.detents = detents
        self.preferredCornerRadius = preferredCornerRadius
        self.prefersGrabberVisible = prefersGrabberVisible
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferredContentSizeWhenEdgeAttached
        self.largestUndimmedDetentIdentifier = largestUndimmedDetentIdentifier
        self.selectedDetentIdentifier = selectedDetentIdentifier
    }

    public func makeUIViewController(context: Context) -> NativePartialSheetController<Content> {
        let viewController = NativePartialSheetController(rootView: content)
        viewController.prefs = self
        return viewController
    }

    public func updateUIViewController(_: NativePartialSheetController<Content>, context: Context) {
    }
}
