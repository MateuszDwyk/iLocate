//
//  iLocateAppApp.swift
//  iLocateApp
//
//  Created by Mateusz Dworaczyk on 29/11/2023.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
 func application(_ application: UIApplication,
                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      print("Configurated firebase")
  return true
 }
}



@main
struct iLocateApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ChoosingView()
        }
    }
}

