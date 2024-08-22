//
//  File.swift
//  
//
//  Created by USER on 8/11/24.
//

import Foundation

protocol GentooSDKDelegate {
    
    typealias Comment = API.CommentResponse
    typealias ItemID = String
    typealias Product = String
    
    func didUpdate(comments: [ItemID: Comment?], gentooSDK: GentooSDK)
    func didUpdate(primaryProducts: [ItemID: Product], gentooSDK: GentooSDK)
    func didUpdate(secondaryProducts: [ItemID: Product], gentooSDK: GentooSDK)
}

public final class GentooSDK {
    
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
    
    public static func initialize(with configuration: Configruation) {
        GentooSDK.shared.initialize(with: configuration)
    }
    
    static let shared = GentooSDK()
    
    private var _configuration: Configruation?
    
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
            
            self.fetchUserID()
        }
    }
    
    func fetchUserID(completionHandler: ((Result<String, any Swift.Error>) -> Void)? = nil) {
        guard let configuration = self._configuration else {
            completionHandler?(.failure(Error.notInitialized))
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            API.dev.fetchUserID(udid: configuration.udid,
                                authCode: configuration.authCode) { result in
                switch result {
                case let .success(userId):
                    self.queue.async {
                        self._userId = userId
                        print("## GENTOO SDK HAS BEEN INITIALIZED SUCCESSFULLY: \(userId)")
                    }
                    completionHandler?(.success(userId))
                case let .failure(error):
                    completionHandler?(.failure(error))
                }
            }
        }
    }
    
    func fetchProduct(itemId: String, userId: String) {
        fetchProduct(itemId: itemId, userId: userId, target: "this")
        fetchProduct(itemId: itemId, userId: userId, target: "needs")
    }
    
    func fetchProduct(itemId: String, userId: String, target: String,
                      completionHandler: ((Result<String, any Swift.Error>) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            API.dev.fetchProduct(itemId: itemId, userId: userId, target: target) { result in
                switch result {
                case .success(let product):
                    print("## PRODUCT(\(target)) LOADED ", product)
                    self.queue.async {
                        if target == "this" {
                            self._products[itemId] = product
                        } else if target == "needs" {
                            self._recommendedProducts[itemId] = product
                        }
                    }
                    completionHandler?(.success(product))
                case .failure(let error):
                    print("Failed to load product with error: \(error.localizedDescription)")
                    completionHandler?(.failure(error))
                }
            }
        }
    }
}
                              
extension GentooSDK {
    enum Error: Swift.Error {
        case notInitialized
        case noItemId
    }
}

extension GentooSDK {
    typealias Comment = API.CommentResponse
    typealias ItemID = String
}
