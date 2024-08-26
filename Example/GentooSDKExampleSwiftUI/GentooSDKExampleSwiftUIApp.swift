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
        
        GentooSDK.initialize(with: .init(udid: "E6252A58-XXXX-XXXX-XXXX-0E5CC7A321D8",
                                         authCode: "Token 32f5fe5e16f62ce8e25ba849xx0000000xx0000x",
                                         clientId: "dlst"))
        
        GentooSDK.onError = {
            print($0.localizedDescription)
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
