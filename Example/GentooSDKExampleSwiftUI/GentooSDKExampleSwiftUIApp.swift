//
//  GentooSDKExampleSwiftUIApp.swift
//  GentooSDKExampleSwiftUI
//
//  Created by USER on 8/26/24.
//

import SwiftUI
import UIKit
import GentooSDK

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Gentoo.initialize(with: .init(udid: "d02a7e31-3727-4e72-8768-88d06d313eed",
                                      authCode: "Token 65ca7bbe5995ac373b06bf3a2c09962a65403245",
                                      clientId: "dlst"))
        
        Gentoo.onLog = {
            print("[Gentoo]", $0.message)
        }
        
        return true
    }
}

@main
struct GentooSDKExampleSwiftUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
