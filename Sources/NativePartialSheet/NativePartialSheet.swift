import Foundation
import NativePartialSheetHelper
import UIKit
import SwiftUI

public enum Detent: Equatable {
    case medium
    case large
    case custom(id: String = UUID().uuidString, constant: CGFloat)
}

extension Detent {
    public var id: UISheetPresentationController.Detent.Identifier {
        switch self {
        case .medium:
            return .medium

        case .large:
            return .large

        case let .custom(id, _):
            return .init(id)
        }
    }

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
    var largestUndimmedDetent: Detent? { get }
    var selectedDetent: Binding<Detent?> { get }
}

public class NativePartialSheetController<Content>: UIHostingController<Content>, UISheetPresentationControllerDelegate where Content : View {
    fileprivate var prefs: Preferences?

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let presentation = sheetPresentationController,
           let prefs = prefs {
            presentation.detents = prefs.detents.map(\.system)
            presentation.prefersGrabberVisible = prefs.prefersGrabberVisible
            presentation.largestUndimmedDetentIdentifier = prefs.largestUndimmedDetent?.id
            presentation.preferredCornerRadius = prefs.preferredCornerRadius
            presentation.prefersEdgeAttachedInCompactHeight = prefs.prefersEdgeAttachedInCompactHeight
            presentation.prefersScrollingExpandsWhenScrolledToEdge = prefs.prefersScrollingExpandsWhenScrolledToEdge
            presentation.widthFollowsPreferredContentSizeWhenEdgeAttached = prefs.widthFollowsPreferredContentSizeWhenEdgeAttached
            presentation.selectedDetentIdentifier = prefs.selectedDetent.wrappedValue?.id
            presentation.delegate = self
        }
        isModalInPresentation = true
    }
    
    public func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        prefs?.selectedDetent.wrappedValue = prefs?.detents.first { $0.id == sheetPresentationController.selectedDetentIdentifier }
    }
}

extension UISheetPresentationController.Detent {
    var myIdentifier: Identifier {
        if #available(iOS 16.0, *) {
            return self.identifier
        } else {
            let test = value(forKey: "identifier")
            debugPrint("ffdf")
            return test as! Identifier
        }
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
    var largestUndimmedDetent: Detent?
    let selectedDetent: Binding<Detent?>
    
    public init(
        detents: [Detent] = [.medium, .large],
        preferredCornerRadius: CGFloat? = nil,
        prefersGrabberVisible: Bool = false,
        prefersEdgeAttachedInCompactHeight: Bool = false,
        prefersScrollingExpandsWhenScrolledToEdge: Bool = true,
        widthFollowsPreferredContentSizeWhenEdgeAttached: Bool = false,
        largestUndimmedDetent: Detent? = nil,
        selectedDetent: Binding<Detent?> = .init(get: { nil }, set: { _ in }),
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.detents = detents
        self.preferredCornerRadius = preferredCornerRadius
        self.prefersGrabberVisible = prefersGrabberVisible
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferredContentSizeWhenEdgeAttached
        self.largestUndimmedDetent = largestUndimmedDetent
        self.selectedDetent = selectedDetent
    }

    public func makeUIViewController(context: Context) -> NativePartialSheetController<Content> {
        let viewController = NativePartialSheetController(rootView: content)
        viewController.prefs = self
        return viewController
    }

    public func updateUIViewController(_ viewController: NativePartialSheetController<Content>, context: Context) {
        if let presentation = viewController.sheetPresentationController {
            presentation.detents = detents.map(\.system)
            presentation.animateChanges {
                presentation.selectedDetentIdentifier = selectedDetent.wrappedValue?.id
            }
        }
        
    }
}
