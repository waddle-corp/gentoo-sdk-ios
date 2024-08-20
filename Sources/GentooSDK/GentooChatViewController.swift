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
    
    private var navigationBar: NavigationBar?
    private var sheetTopBar: SheetTopBar?
    private var activityIndicator: UIActivityIndicatorView!
    private var webView: WKWebView!
    
    private var isSheet: Bool {
        return navigationController?.viewControllers.firstIndex(of: self) == nil
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 535)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        // TODO: Remove this later (for test purpose only)
        try? self.fetchExampleProduct { result in
            switch result {
            case let .success(info):
                if let url = self.constructURL(productInfo: info) {
                    let request = URLRequest(url: url)
                    DispatchQueue.main.async {
                        self.webView.load(request)
                    }
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func constructURL(productInfo: String) -> URL? {
        
        return URL(string: "https://demo.gentooai.com/demo/288335308/demo_ck")!
        
        let clientId = "dlst"
        let userId = "432883135"
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "dev-demo.gentooai.com"
        components.path = "/\(clientId)/sdk/\(userId)"
        components.queryItems = [
            URLQueryItem(name: "product", value: productInfo)
        ]
        
        return components.url
    }
    
    private func fetchExampleProduct(completionHandler: @escaping (Result<String, Error>) -> Void) throws {
        var request = URLRequest(url: URL(string: "https://hg5eey52l4.execute-api.ap-northeast-2.amazonaws.com/dev/recommend")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "itemId": 752,
            "userId": 432883135,
            "target": "this",
            "channelId": "mobile"
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                completionHandler(.failure(error))
            } else if let data {
                completionHandler(.success(String(data: data, encoding: .utf8)!))
            } else {
                completionHandler(.failure(URLError(.unknown)))
            }
        }
        
        task.resume()
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
