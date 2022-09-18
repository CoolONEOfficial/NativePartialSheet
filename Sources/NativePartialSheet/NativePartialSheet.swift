import Foundation
import NativePartialSheetHelper
import UIKit
import SwiftUI

public enum Detent {
    public static let defaultId = "default_id"
    
    case medium
    case large
    case custom(id: String = Detent.defaultId, constant: CGFloat)

    var system: UISheetPresentationController.Detent {
        switch self {
        case .medium:
            return .medium()

        case .large:
            return .large()

        case let .custom(id, constant):
            if #available(iOS 16.0, *) {
                return .custom(identifier: id == Detent.defaultId ? nil : .init(rawValue: id), resolver: {_ in constant})
            } else {
                return ._detent(withIdentifier: id, constant: constant)
            }
        }
    }
}

public class PartialSheetController<Content>: UIHostingController<Content> where Content : View {
    var detents: [Detent] = []

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let presentation = sheetPresentationController {
            presentation.detents = detents.map(\.system)
            presentation.prefersGrabberVisible = true
            presentation.largestUndimmedDetentIdentifier = .medium
        }
        isModalInPresentation = true
    }
}

public struct PartialSheet<Content>: UIViewControllerRepresentable where Content : View {

    public let content: Content
    public let detents: [Detent]

    @inlinable public init(detents: [Detent], @ViewBuilder content: () -> Content) {
        self.content = content()
        self.detents = detents
    }

    public func makeUIViewController(context: Context) -> PartialSheetController<Content> {
        let viewController = PartialSheetController(rootView: content)
        viewController.detents = detents
        return viewController
    }

    public func updateUIViewController(_: PartialSheetController<Content>, context: Context) {
    }
}
