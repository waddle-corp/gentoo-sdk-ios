//
//  File.swift
//  
//
//  Created by USER on 8/11/24.
//

import Foundation

public final class Gentoo {
    
    public struct Configruation: Sendable {
        public var udid: String
        public var authCode: String
        public var clientId: String
        
        public init(udid: String, authCode: String, clientId: String) {
            self.udid = udid
            self.authCode = authCode
            self.clientId = clientId
        }
    }
    
    public struct Log {
        public enum Level: String {
            case info
            case warning
            case error
        }
        
        public let time: Date
        public let level: Level
        public let message: String
    }
    
    public static func initialize(with configuration: Configruation) {
        Gentoo.shared.initialize(with: configuration)
    }
    
    public static var onLog: ((Log) -> Void)? {
        get { Gentoo.shared.queue.sync { Gentoo.shared._logHandler } }
        set { Gentoo.shared.queue.sync { Gentoo.shared._logHandler = newValue } }
    }
    
    static let shared = Gentoo()
    
    private var _configuration: Configruation?
    
    private static var enablesWebviewPreloading: Bool { false }
    
    var configuration: Configruation? {
        self.queue.sync { _configuration }
    }
    
    private var _userId: String?
    
    var userId: String? {
        self.queue.sync { _userId }
    }
    
    var isInitialized: Bool {
        self.queue.sync { _configuration != nil }
    }
    
    private var _products: [ItemID: String] = [:]
    
    var products: [ItemID: String] {
        self.queue.sync { _products }
    }
    
    private var _recommendedProducts: [ItemID: String] = [:]
    
    var recommendedProducts: [ItemID: String] {
        self.queue.sync { _recommendedProducts }
    }
    
    private var _webViews: [ContentType: GentooWebView] = [:]
    
    var webViews: [ContentType: GentooWebView] {
        self.queue.sync { _webViews }
    }
    
    private var _logHandler: ((Log) -> Void)?
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.waddlecorp.gentoo-sdk.queue")
    
    private init() {}
    
    private func initialize(with configuration: Configruation) {
        self.queue.async {
            // userId 요청이 필요없는 경우는 API 호출하지 않는다.
            if self._userId != nil,
               self._configuration?.udid == configuration.udid,
               self._configuration?.authCode == configuration.authCode,
               self._configuration?.clientId == configuration.clientId {
                return
            }
            
            self._configuration = configuration
            
            self.fetchUserID { result in
                switch result {
                case let .success(userId):
                    Gentoo.shared.publishLog(level: .info, message: "Initialized successfully with userId: \(userId)")
                case let .failure(error):
                    Gentoo.shared.publishLog(level: .error, message: "Failed to initialize with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchUserID(completionHandler: ((Result<String, any Swift.Error>) -> Void)? = nil) {
        guard let configuration = self._configuration else {
            completionHandler?(.failure(Error.notInitialized))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            API.prod.fetchUserID(udid: configuration.udid,
                                authCode: configuration.authCode) { result in
                switch result {
                case let .success(userId):
                    self.queue.async {
                        self._userId = userId
                    }
                    completionHandler?(.success(userId))
                case let .failure(error):
                    completionHandler?(.failure(error))
                }
            }
        }
    }
    
    func fetchProduct(itemId: String, userId: String) {
        fetchProduct(itemId: itemId, userId: userId, target: "this", completionHandler: { result in
            if case .success = result {
                DispatchQueue.main.async {
                    self.preloadWebView(itemId: itemId, contentType: .normal)
                }
            }
        })
        fetchProduct(itemId: itemId, userId: userId, target: "needs")
    }
    
    func fetchProduct(itemId: String, userId: String, target: String,
                      completionHandler: ((Result<String, any Swift.Error>) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            API.prod.fetchProduct(itemId: itemId, userId: userId, target: target) { result in
                switch result {
                case .success(let product):
                    self.queue.async {
                        if target == "this" {
                            self._products[itemId] = product
                        } else if target == "needs" {
                            self._recommendedProducts[itemId] = product
                        }
                    }
                    completionHandler?(.success(product))
                    Gentoo.shared.publishLog(level: .info, message: "Successfully fetched product(\(target)) information for itemId: \(itemId)")
                case .failure(let error):
                    Gentoo.shared.publishLog(level: .error, message: "Failed to fetch product(\(target)) information for itemId: \(itemId), error: \(error.localizedDescription)")
                    completionHandler?(.failure(error))
                }
            }
        }
    }
    
    func preloadWebView(itemId: String, contentType: Gentoo.ContentType) {
        
        guard Self.enablesWebviewPreloading else { return }
        
        var needsPreload = false
        
        self.queue.sync {
            needsPreload = self._webViews[contentType] == nil
        }
        
        guard needsPreload else { return }
        
        let webView = GentooWebView()
        webView.contentType = contentType
        webView.loadWebPage(itemId: itemId)
        
        self.queue.sync {
            guard self._webViews[contentType] == nil else { return }
            self._webViews[contentType] = webView
        }
    }
    
    func discardPreloadedWebView(contentType: Gentoo.ContentType) {
        self.queue.sync {
            self._webViews[contentType] = nil
        }
    }
    
    func publishLog(level: Log.Level, message: String) {
        let log = Log(time: Date(), level: level, message: message)
        self.queue.async {
            self._logHandler?(log)
        }
    }
}
                              
extension Gentoo {
    enum Error: LocalizedError {
        case notInitialized
        
        var errorDescription: String? {
            switch self {
            case .notInitialized:
                return "GentooSDK has not been initialized."
            }
        }
    }
}

extension Gentoo {
    typealias Comment = API.CommentResponse
    typealias ItemID = String
}

extension Gentoo {
    public enum ContentType {
        case normal
        case recommendation
    }
}
