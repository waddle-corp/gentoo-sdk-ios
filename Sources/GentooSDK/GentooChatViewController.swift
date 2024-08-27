//
//  GentooChatViewController.swift
//  GentooSDK
//
//  Created by John on 8/7/24.
//

import UIKit
import SwiftUI
import WebKit

public class GentooChatViewController: UIViewController {
    
    public typealias ContentType = GentooSDK.ContentType
    
    public private(set) var contentType: ContentType = .normal
    
    public var itemId: String?
    
    var _enablesPanGestureRecognizer = true
    var _showsNavigationBar: Bool?
    
    private var navigationBar: NavigationBar?
    private var sheetTopBar: SheetTopBar?
    private var activityIndicator: UIActivityIndicatorView!
    private var gentooWebView: GentooWebView!
    
    private var _isSheet: Bool?
    private var isSheet: Bool {
        return _isSheet ?? (navigationController?.viewControllers.firstIndex(of: self) == nil)
    }
    
    public init(itemId: String, contentType: GentooSDK.ContentType) {
        self.itemId = itemId
        self.contentType = contentType
        super.init(nibName: nil, bundle: nil)
        didInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        didInit()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        didInit()
    }
    
    private func didInit() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 535)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if let _showsNavigationBar {
            if _showsNavigationBar {
                _isSheet = false
                setupNavigationBar()
            } else {
                _isSheet = true
                setupSheetTopBar()
            }
        } else if isSheet {
            setupSheetTopBar()
        } else {
            setupNavigationBar()
        }
        
        setupGentooWebView()
        setupActivityIndicator()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        GentooSDK.shared.discardPreloadedWebView(contentType: contentType)
        if let itemId {
            GentooSDK.shared.preloadWebView(itemId: itemId, contentType: contentType)
        }
    }
    
    private func setupSheetTopBar() {
        let sheetTopBar = SheetTopBar()
        self.sheetTopBar = sheetTopBar
        view.addSubview(sheetTopBar)
        sheetTopBar.closeButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        sheetTopBar.translatesAutoresizingMaskIntoConstraints = false
        
        if _enablesPanGestureRecognizer {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            sheetTopBar.addGestureRecognizer(panGesture)
        }
        
        NSLayoutConstraint.activate([
            sheetTopBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetTopBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetTopBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sheetTopBar.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func setupNavigationBar() {
        let navigationBar = NavigationBar()
        self.navigationBar = navigationBar
        view.addSubview(navigationBar)
        navigationBar.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupGentooWebView() {
        if let preloadedWebView = GentooSDK.shared.webViews[contentType],
           preloadedWebView.itemId == self.itemId,
           preloadedWebView.contentType == self.contentType {
            gentooWebView = preloadedWebView
            gentooWebView.reloadWebPage()
        } else {
            gentooWebView = GentooWebView()
            gentooWebView.contentType = contentType
            
            if let itemId = itemId {
                gentooWebView.loadWebPage(itemId: itemId)
            }
        }
        
        gentooWebView.delegate = self
        
        view.addSubview(gentooWebView)
        gentooWebView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gentooWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gentooWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gentooWebView.topAnchor.constraint(equalTo: isSheet ? sheetTopBar!.bottomAnchor : navigationBar!.bottomAnchor),
            gentooWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: gentooWebView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: gentooWebView.centerYAnchor)
        ])
    }
    
    @objc private func backButtonTapped() {
        if isSheet {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
        guard _enablesPanGestureRecognizer else { return }
        
        guard let customPresentationController = self.presentationController as? CustomPresentationController else { return }
        
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                view.transform = CGAffineTransform(translationX: 0, y: translation.y)
            } else {
                let newY = customPresentationController.collapsedFrame.origin.y + translation.y
                let newHeight = customPresentationController.containerView!.bounds.height - newY
                self.view.frame = CGRect(
                    x: 0,
                    y: newY,
                    width: self.view.bounds.width,
                    height: newHeight
                )
            }
        case .ended:
            let velocity = gesture.velocity(in: view)
            
            if translation.y > 200 || velocity.y > 500 {
                dismiss(animated: true, completion: nil)
            } else if translation.y < -100 || velocity.y < -500 {
                customPresentationController.expandToFullScreen {
                    // WebView 콘텐츠가 로드가 되기 전에 expand되면 content 영역이 잘리는 경우가 있는데, 이 경우에는 reload해준다.
                    self.gentooWebView.reloadWebPageIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = .identity
                    self.view.frame = customPresentationController.frameOfPresentedViewInContainerView
                }
            }
        default:
            break
        }
    }
}

extension GentooChatViewController: GentooWebViewDelegate {
    
    // MARK: GentooWebViewDelegate methods
    func webViewDidStartLoading(_ webView: GentooWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoading(_ webView: GentooWebView) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: GentooWebView, didFailWithError error: Error) {
        activityIndicator.stopAnimating()
    }
    
    func webViewDidFocusInput(_ webView: GentooWebView) {
        guard let customPresentationController = self.presentationController as? CustomPresentationController,
              customPresentationController.isExpanded == false else {
            return
        }
        
        customPresentationController.expandToFullScreen {
            self.gentooWebView.scrollToBottom()
        }
    }
}


@available(iOS 13.0, *)
public struct GentooChatView: View {
    
    public let itemId: String
    public let contentType: GentooSDK.ContentType
    
    public init(itemId: String, contentType: GentooSDK.ContentType) {
        self.itemId = itemId
        self.contentType = contentType
    }
    
    public var body: some View {
        Inner(itemId: itemId, contentType: contentType, showsNavigationBar: true)
    }
    
    struct Inner: UIViewControllerRepresentable {
        
        let itemId: String
        let contentType: GentooSDK.ContentType
        let showsNavigationBar: Bool
        
        func makeUIViewController(context: Context) -> GentooChatViewController {
            let vc = GentooChatViewController(itemId: itemId, contentType: contentType)
            vc._enablesPanGestureRecognizer = false
            vc._showsNavigationBar = self.showsNavigationBar
            return vc
        }
        
        func updateUIViewController(_ uiViewController: GentooChatViewController, context: Context) {}
    }
}
