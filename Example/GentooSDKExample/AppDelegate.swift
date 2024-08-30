//
//  AppDelegate.swift
//  GentooSampleApp
//
//  Created by USER on 8/6/24.
//

import UIKit
import GentooSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Gentoo.initialize(with: .init(udid: "d02a7e31-3727-4e72-8768-88d06d313eed",
                                      authCode: "Token 65ca7bbe5995ac373b06bf3a2c09962a65403245",
                                      clientId: "dlst"))
        
        Gentoo.onLog = {
            print("[Gentoo]", $0.message)
        }
        
        return true
        
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

