import Foundation
import NativePartialSheetHelper
import UIKit
import SwiftUI
import os

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "NativePartialSheet"
)

class SheetViewController: UIViewController {
    var sheetShadowColor: UIColor?
    var sheetShadowOffset: CGSize?
    var sheetShadowRadius: CGFloat?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let shadow = view.firstParentWithClassName("UIDropShadowView") {
            if let color = sheetShadowColor {
                shadow.layer.shadowColor = color.cgColor
            }
            if let offset = sheetShadowOffset {
                shadow.layer.shadowOffset = offset
            }
            if let radius = sheetShadowRadius {
                shadow.layer.shadowRadius = radius
            }
        }
    }
}

struct NativePartialSheetView<PrefContent: View>: UIViewRepresentable {
    
    private let prefs: Preferences<PrefContent>

    init(
        _ prefs: Preferences<PrefContent>
    ) {
        self.prefs = prefs
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }
    
    @ViewBuilder
    var rootView: some View {
        if prefs.isPresented.wrappedValue {
            prefs.content().onDisappear {
                prefs.isPresented.wrappedValue = false // bugfix for `https://github.com/CoolONEOfficial/NativePartialSheet/issues/2`
            }
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        let viewController = SheetViewController()
        viewController.sheetShadowColor = prefs.sheetShadowColor
        viewController.sheetShadowOffset = prefs.sheetShadowOffset
        viewController.sheetShadowRadius = prefs.sheetShadowRadius

        let hostingController = UIHostingController(rootView: rootView)
        
        viewController.addChild(hostingController)
        viewController.view.addSubview(hostingController.view)

        hostingController.view.backgroundColor = prefs.sheetColor
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.leftAnchor.constraint(equalTo: viewController.view.leftAnchor).isActive = true
        hostingController.view.topAnchor.constraint(equalTo: viewController.view.topAnchor).isActive = true
        hostingController.view.rightAnchor.constraint(equalTo: viewController.view.rightAnchor).isActive = true
        hostingController.view.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor).isActive = true
        hostingController.didMove(toParent: viewController)
        
        viewController.isModalInPresentation = prefs.interactiveDismissDisabled
        
        if let sheetController = viewController.presentationController as? UISheetPresentationController {
            sheetController.detents = prefs.detents.map(\.system)
            sheetController.prefersGrabberVisible = prefs.presentationDragIndicator == .visible
            sheetController.largestUndimmedDetentIdentifier = prefs.largestUndimmedDetent?.id
            sheetController.preferredCornerRadius = prefs.preferredCornerRadius
            sheetController.prefersEdgeAttachedInCompactHeight = prefs.prefersEdgeAttachedInCompactHeight
            sheetController.prefersScrollingExpandsWhenScrolledToEdge = prefs.prefersScrollingExpandsWhenScrolledToEdge
            sheetController.widthFollowsPreferredContentSizeWhenEdgeAttached = prefs.widthFollowsPreferredContentSizeWhenEdgeAttached
            sheetController.selectedDetentIdentifier = prefs.selectedDetent.wrappedValue.id
            sheetController.delegate = context.coordinator
        }
        
        guard let window = uiView.window ?? UIApplication.shared.keyWindow else {
            logger.warning("Root window not found")
            return
        }
        guard let rootViewController = window.rootViewController ?? UIApplication.shared.keyWindowPresentedController else {
            logger.warning("Root VC not found")
            return
        }
        
        let presentedViewController = rootViewController.presentedViewController
        
        let isPresented = prefs.isPresented.wrappedValue
        let actual = presentedViewController != nil
        if actual != isPresented {
            if isPresented {
                rootViewController.present(viewController, animated: true)
            } else if presentedViewController is SheetViewController {
                rootViewController.dismiss(animated: true)
            }
        } else if actual, let sheetController = presentedViewController?.presentationController as? UISheetPresentationController {
            sheetController.animateChanges {
                sheetController.selectedDetentIdentifier = prefs.selectedDetent.wrappedValue.id
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UISheetPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate {
        private let parent: NativePartialSheetView
        
        init(_ parent: NativePartialSheetView) {
            self.parent = parent
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.prefs.isPresented.wrappedValue = false
            parent.prefs.onDidDismiss?()
        }
        
        func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
            guard let id = sheetPresentationController.selectedDetentIdentifier else {
                return
            }
            guard let detent = Detent(id: id) else {
                logger.warning("Cannot parse height from detent identifier")
                return
            }
            parent.prefs.selectedDetent.wrappedValue = detent
        }
        
        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            parent.prefs.onWillDismiss?()
        }
    }
    
}
