//
//  GentooChatViewController.SheetTopBar.swift
//  GentooSDK
//
//  Created by John on 8/7/24.
//

import UIKit

extension GentooChatViewController {
    
    final class SheetTopBar: UIView {
        
        private let dragHandle: UIView = {
            let handle = UIView()
            handle.backgroundColor = UIColor(hexString: "E1E1E1")
            handle.layer.cornerRadius = 2
            return handle
        }()
        
        let closeButton: UIButton = {
            let button = UIButton(type: .custom)
            button.setImage(ImageProvider.loadImage(named: "icn_close"), for: .normal)
            button.tintColor = UIColor(hexString: "666666")
            return button
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupView() {
            addSubview(dragHandle)
            addSubview(closeButton)
            
            setupConstraints()
        }
        
        private func setupConstraints() {
            dragHandle.translatesAutoresizingMaskIntoConstraints = false
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                dragHandle.centerXAnchor.constraint(equalTo: centerXAnchor),
                dragHandle.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                dragHandle.widthAnchor.constraint(equalToConstant: 44),
                dragHandle.heightAnchor.constraint(equalToConstant: 4),
                
                closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                closeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: 24),
                closeButton.heightAnchor.constraint(equalToConstant: 24),
            ])
        }
    }
    
}


extension GentooChatViewController: UIViewControllerTransitioningDelegate {

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class CustomPresentationController: UIPresentationController {
    
    private var dimmingView: UIView!
    private var bottomSafeAreaBackgroundView: UIView!
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    var expandedFrame: CGRect {
        guard let containerView = containerView else { return .zero }
        let topSafeAreaInset = containerView.safeAreaInsets.top
        let bottomSafeAreaInset = containerView.safeAreaInsets.bottom
        return CGRect(x: 0, y: topSafeAreaInset, width: containerView.bounds.width, height: containerView.bounds.height - topSafeAreaInset - bottomSafeAreaInset)
    }
    
    var collapsedFrame: CGRect {
        guard let containerView = containerView else { return .zero }
        let size = presentedViewController.preferredContentSize
        let origin = CGPoint(x: 0, y: containerView.bounds.height - size.height)
        return CGRect(origin: origin, size: size)
    }
    
    var isExpanded = false
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return isExpanded ? expandedFrame : collapsedFrame
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
        
        containerView.addSubview(dimmingView)
        
        bottomSafeAreaBackgroundView = UIView()
        bottomSafeAreaBackgroundView.backgroundColor = .white
        containerView.addSubview(bottomSafeAreaBackgroundView)
        bottomSafeAreaBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomSafeAreaBackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bottomSafeAreaBackgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bottomSafeAreaBackgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            bottomSafeAreaBackgroundView.heightAnchor.constraint(equalToConstant: containerView.safeAreaInsets.bottom)
        ])

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            dimmingView.alpha = 1.0
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        if let dimmingView = containerView?.subviews.first {
            presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
                dimmingView.alpha = 0.0
            }, completion: { _ in
                dimmingView.removeFromSuperview()
            })
        }
        bottomSafeAreaBackgroundView.removeFromSuperview()
    }
    
    @objc private func dimmingViewTapped() {
        if !isExpanded {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func expandToFullScreen() {
        guard let containerView = containerView else { return }
        isExpanded = true
        UIView.animate(withDuration: 0.3) {
            self.presentedView?.frame = self.expandedFrame
            containerView.layoutIfNeeded()
        }
    }
    
    func collapseToOriginalSize() {
        isExpanded = false
        UIView.animate(withDuration: 0.3) {
            self.presentedView?.frame = self.collapsedFrame
        }
    }
}

