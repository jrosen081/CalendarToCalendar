//
//  BottomSheet.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/9/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI

struct BottomSheet<Content: View, Overlay: View>: View {
    @Binding var isOpen: Bool
    let content: Content
    let overlay: Overlay
    @Environment(\.backgroundColor) var backgroundColor

    @ViewBuilder
    private var overlayView: some View {
        PresentingRepresentable(view: overlay.padding(), isPresented: $isOpen)
    }

    var body: some View {
        content
            .background(overlayView)
    }
}

private struct PresentingRepresentable<Data: View>: UIViewControllerRepresentable {
    let view: Data
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIViewController()
        return controller
    }

    private class HoldingController: UIHostingController<Data> {
        let onDismiss: () -> Void

        init(rootView: Data, onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
            super.init(rootView: rootView)
        }

        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override var preferredContentSize: CGSize {
            get {
                let bounds = UIScreen.main.bounds
                return CGSize(width: bounds.width,
                              height: bounds.height / 2)
            }
            set { }
        }

        deinit {
            onDismiss()
        }
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if isPresented, uiViewController.presentedViewController == nil {
            let newController = HoldingController(rootView: view) { [$isPresented] in
                $isPresented.wrappedValue = false
            }
            let wrapperVC = UIViewController()
            wrapperVC.addChild(newController)
            wrapperVC.view.addSubview(newController.view)
            newController.view.translatesAutoresizingMaskIntoConstraints = false
            wrapperVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                newController.view.bottomAnchor.constraint(equalTo: wrapperVC.view.bottomAnchor),
                newController.view.topAnchor.constraint(equalTo: wrapperVC.view.topAnchor),
                newController.view.leadingAnchor.constraint(equalTo: wrapperVC.view.leadingAnchor),
                newController.view.trailingAnchor.constraint(equalTo: wrapperVC.view.trailingAnchor)
            ])
            wrapperVC.modalPresentationStyle = .formSheet
            wrapperVC.sheetPresentationController?.detents = [.medium()]
            uiViewController.present(wrapperVC, animated: true)
        } else if !isPresented, uiViewController.presentedViewController?.children.first is UIHostingController<Data> {
            uiViewController.presentedViewController?.dismiss(animated: true)
        }
    }
}

public extension View {
    func bottomSheet(isOpen: Binding<Bool>, overlay: () -> some View) -> some View {
        BottomSheet(isOpen: isOpen, content: self, overlay: overlay())
    }
}
