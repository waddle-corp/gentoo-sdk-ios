//
//  GentooWebView.swift
//
//
//  Created by USER on 8/23/24.
//

import UIKit
import WebKit

protocol GentooWebViewDelegate: AnyObject {
    func webViewDidStartLoading(_ webView: GentooWebView)
    func webViewDidFinishLoading(_ webView: GentooWebView)
    func webView(_ webView: GentooWebView, didFailWithError error: Error)
    func webViewDidFocusInput(_ webView: GentooWebView)
}

final class GentooWebView: UIView, WKNavigationDelegate {
    
    var webView: WKWebView!
    weak var delegate: GentooWebViewDelegate?
    
    private var isReloading = false
    private let inputFocusEventListener = GentooInputFocusEventListener()
    
    var isSheet: Bool = true
    
    private(set) var itemId: String?
    var contentType: Gentoo.ContentType = .normal
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWebView()
    }
    
    private func setupWebView() {
        
        inputFocusEventListener.delegate = self
        
        let configuration = WKWebViewConfiguration()
        configuration.suppressesIncrementalRendering = true
        configuration.websiteDataStore = .nonPersistent()
        
        configuration.userContentController.add(
            inputFocusEventListener,
            name: GentooInputFocusEventListener.name
        )
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.scrollView.showsVerticalScrollIndicator = false
#if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
        
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public func loadWebPage(itemId: String?) {
        self.itemId = itemId
        constructURL(itemId: itemId) { result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self.webView.load(URLRequest(url: url))
                }
            case .failure(let error):
                self.delegate?.webView(self, didFailWithError: error)
            }
        }
    }
    
    func reloadWebPageIfNeeded() {
        if webView.scrollView.contentSize != webView.scrollView.bounds.size {
            reloadWebPage()
        }
    }
     
    func reloadWebPage() {
        webView.reload()
    }
    
    func scrollToBottom() {
        let scrollToBottomScript = "window.scrollTo(0, document.body.scrollHeight);"
        webView.evaluateJavaScript(scrollToBottomScript, completionHandler: nil)
    }
    
    private func constructURL(itemId: String?, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        
        let userIdHandler: (String) -> Void = { userId in
            self.constructURL(itemId: itemId, userId: userId, completionHandler: completionHandler)
        }
        
        if let userId = Gentoo.shared.userId {
            userIdHandler(userId)
        } else {
            Gentoo.shared.fetchUserID { result in
                switch result {
                case .success(let userId):
                    userIdHandler(userId)
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    private func constructURL(itemId: String?,
                              userId: String,
                              completionHandler: @escaping (Result<URL, Error>) -> Void) {
        guard let configuration = Gentoo.shared.configuration else {
            completionHandler(.failure(Gentoo.Error.notInitialized))
            return
        }
        
        guard isSheet, let itemId else {
            let globalChatURL = URL.globalChatURL(clientId: configuration.clientId, userId: userId)
            completionHandler(.success(globalChatURL))
            return
        }
        
        var product: String?
        
        if contentType == .normal {
            product = Gentoo.shared.products[itemId]
        } else {
            product = Gentoo.shared.recommendedProducts[itemId]
        }
        
        if let product {
            let chatURL = URL.chatURL(clientId: configuration.clientId, userId: userId, product: product)
            completionHandler(.success(chatURL))
        } else {
            Gentoo.shared.fetchProduct(itemId: itemId,
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
    
    // MARK: WKNavigationDelegate methods
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        delegate?.webViewDidStartLoading(self)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.webViewDidFinishLoading(self)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.webView(self, didFailWithError: error)
    }
}

extension GentooWebView: GentooInputFocusEventListenerDelegate {
    func didReceiveFocusEvent(listener: GentooInputFocusEventListener) {
        delegate?.webViewDidFocusInput(self)
    }
}

private extension URL {
    
    static func globalChatURL(clientId: String, userId: String) -> Self {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "dev-demo.gentooai.com"
        components.path = "/\(clientId)/\(userId)"
        return components.url!
    }
    
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
