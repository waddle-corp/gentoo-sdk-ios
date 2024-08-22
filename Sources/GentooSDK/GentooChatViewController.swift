//
//  GentooChatViewController.swift
//  GentooSDK
//
//  Created by John on 8/7/24.
//

import UIKit
import SwiftUI
import WebKit

open class GentooChatViewController: UIViewController, WKNavigationDelegate {
    
    public enum ContentType {
        case normal
        case recommendation
    }
    
    public private(set) var contentType: ContentType = .normal
    
    public var itemId: String?
    
    private var navigationBar: NavigationBar?
    private var sheetTopBar: SheetTopBar?
    private var activityIndicator: UIActivityIndicatorView!
    private var webView: WKWebView!
    
    private var isSheet: Bool {
        return navigationController?.viewControllers.firstIndex(of: self) == nil
    }
    
    public init(itemId: String, contentType: ContentType) {
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
        
        if isSheet {
            setupSheetTopBar()
        } else {
            setupNavigationBar()
        }
        
        setupWebView()
        setupActivityIndicator()
        loadWebPage()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupSheetTopBar() {
        let sheetTopBar = SheetTopBar()
        self.sheetTopBar = sheetTopBar
        view.addSubview(sheetTopBar)
        sheetTopBar.closeButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        sheetTopBar.translatesAutoresizingMaskIntoConstraints = false
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        sheetTopBar.addGestureRecognizer(panGesture)
        
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
    
    private func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
#if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: isSheet ? sheetTopBar!.bottomAnchor : navigationBar!.bottomAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
        ])
    }
    
    private func loadWebPage() {
        constructURL(completionHandler: { result in
            switch result {
            case .success(let url):
                let request = URLRequest(url: url)
                DispatchQueue.main.async {
                    self.webView.load(request)
                }
            case .failure(let error):
                print("Failed to load web page: \(error.localizedDescription)")
            }
        })
    }
    
    private func constructURL(completionHandler: @escaping (Result<URL, Error>) -> Void) {
        guard let itemId = self.itemId else {
            completionHandler(.failure(GentooSDK.Error.noItemId))
            return
        }
        
        if let userId = GentooSDK.shared.userId {
            constructURL(itemId: itemId, userId: userId, completionHandler: completionHandler)
        } else {
            GentooSDK.shared.fetchUserID { result in
                switch result {
                case .success(let userId):
                    self.constructURL(itemId: itemId, userId: userId, completionHandler: completionHandler)
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    private func constructURL(itemId: String,
                              userId: String,
                              completionHandler: @escaping (Result<URL, Error>) -> Void) {
        guard let configuration = GentooSDK.shared.configuration else {
            completionHandler(.failure(GentooSDK.Error.notInitialized))
            return
        }
        
        // Check if the product exists already.
        var product: String?
        
        if contentType == .normal {
            product = GentooSDK.shared.products[itemId]
        } else {
            product = GentooSDK.shared.recommendedProducts[itemId]
        }
        
        if let product {
            let chatURL = URL.chatURL(clientId: configuration.clientId, userId: userId, product: product)
            completionHandler(.success(chatURL))
        } else {
            GentooSDK.shared.fetchProduct(itemId: itemId,
                                          userId: userId,
                                          target: contentType == .normal ? "this" : "needs") { result in
                switch result {
                case .success(let product):
                    let chatURL = URL.chatURL(clientId: configuration.clientId, userId: userId, product: product)
                    completionHandler(.success(chatURL))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    
    @objc private func backButtonTapped() {
        if isSheet {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
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
                customPresentationController.expandToFullScreen()
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
    
    // MARK: WKNavigationDelegate methods
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}


@available(iOS 13.0, *)
public struct GentooChatView: UIViewControllerRepresentable {
    
    public init() {}
    
    public func makeUIViewController(context: Context) -> GentooChatViewController {
        GentooChatViewController()
    }

    public func updateUIViewController(_ uiViewController: GentooChatViewController, context: Context) {
        
    }
}

private extension URL {
    static func chatURL(clientId: String, userId: String, product: String) -> Self {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "dev-demo.gentooai.com"
        components.path = "/\(clientId)/sdk/\(userId)"
        components.queryItems = [
            URLQueryItem(name: "product", value: product)
        ]
        return components.url!
    }
}

