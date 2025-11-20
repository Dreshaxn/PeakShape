//
//  PeakShapeApp.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct PeakShapeApp: App {
    // 👇 Create the AuthViewModel once for the whole app
    @StateObject var authViewModel = AuthViewModel()
    
    // 👇 Initialize Firebase when app starts
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
           AuthGateView()  // 👈 This will show login or home
                .environmentObject(authViewModel) // 👈 Inject the view model
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
            
        }
    }
}
