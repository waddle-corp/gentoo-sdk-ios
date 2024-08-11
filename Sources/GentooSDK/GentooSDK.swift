//
//  File.swift
//  
//
//  Created by USER on 8/11/24.
//

import Foundation

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
    
    private(set) var udid: String?
    private(set) var authCode: String?
    private(set) var clientId: String?
    
    private let lock = NSLock()
    
    private init() {}
    
    private func initialize(with configuration: Configruation) {
        self.lock.lock()
        self.udid = configuration.udid
        self.authCode = configuration.authCode
        self.clientId = configuration.clientId
        self.lock.unlock()
    }
    
}
