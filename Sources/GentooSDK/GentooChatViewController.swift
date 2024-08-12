//
//  GentooChatViewController.swift
//  GentooSDK
//
//  Created by John on 8/7/24.
//

import UIKit
import WebKit

open class GentooChatViewController: UIViewController, WKNavigationDelegate {
    
    private let navigationBar = NavigationBar()
    private var activityIndicator: UIActivityIndicatorView!
    private var webView: WKWebView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
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
    
    private func setupNavigationBar() {
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
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
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
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
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
