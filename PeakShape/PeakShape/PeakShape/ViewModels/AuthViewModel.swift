import Foundation
import FirebaseAuth
import Combine
import SwiftUI
import UIKit
import AuthenticationServices
import CryptoKit
import GoogleSignIn


// This ViewModel manages authentication state and actions for the app.
class AuthViewModel: ObservableObject {
    // The current Firebase user (nil if not logged in)
    @Published var user: User?
    // Any error message to show in the UI
    @Published var errorMessage: String?
    // Track if user has completed onboarding
    @Published var hasCompletedOnboarding: Bool = false
    
    @Published var phoneNumber: String = ""
    @Published var smsCode: String = ""
    @Published var verificationID: String? = nil
    
    @Published var isLoading: Bool = false

    
    // Listener for auth state changes
    private var handle: AuthStateDidChangeListenerHandle?
    
    // Apple Sign-In nonce
    private var currentNonce: String?
    
    // Set up the listener when the ViewModel is created
    init() {
        // Listen for changes in authentication state
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async { self?.user = user } // Update the user property
        }
    }
    
    // Remove the listener when the ViewModel is destroyed
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    /*
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    */
    
    // MARK: - Email / Password
    func login(email: String, password: String) {
        errorMessage = nil // Clear any previous error
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    // If there's an error, show it
                    self?.errorMessage = error.localizedDescription
                } else {
                    // If successful, update the user
                    self?.user = result?.user
                }
            }
        }
    }
    
    // MARK: Register a new user with email and password
    func register(email: String, password: String) {
        errorMessage = nil // Clear any previous error
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    // If there's an error, show it
                    self?.errorMessage = error.localizedDescription
                } else {
                    // If successful, update the user
                    self?.user = result?.user
                }
            }
        }
    }
    
    // MARK: Sign out the current user
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil // Clear the user
            self.hasCompletedOnboarding = false // Reset onboarding state
        } catch {
            // If there's an error signing out, show it
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: Mark onboarding as completed
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    

    // MARK: - Google 
    
     func signInWithGoogle(presenting vc: UIViewController) {
         errorMessage = nil
         GIDSignIn.sharedInstance.signIn(withPresenting: vc) { [weak self] result, error in
             if let error = error {
                 DispatchQueue.main.async { self?.errorMessage = error.localizedDescription }
                 return
             }
             guard
                 let self,
                 let idToken = result?.user.idToken?.tokenString,
                 let accessToken = result?.user.accessToken.tokenString
             else {
                 DispatchQueue.main.async { self?.errorMessage = "Google sign-in failed." }
                 return
             }
             let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
             Auth.auth().signIn(with: credential) { authResult, error in
                 DispatchQueue.main.async {
                     if let error = error {
                         self.errorMessage = error.localizedDescription
                         return
                     }
                     self.user = authResult?.user
                 }
             }
         }
     }
     

    // MARK: - Apple
    func makeAppleIDRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            
        case .success(let auth):
            guard
                let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                let identityTokenData = credential.identityToken,
                let identityToken = String(data: identityTokenData, encoding: .utf8),
                let nonce = currentNonce
            else {
                self.errorMessage = "Unable to fetch Apple identity token."
                return
            }
            let firebaseCredential = OAuthProvider.credential(
                providerID: .apple,
                idToken: identityToken,
                rawNonce: nonce,
                accessToken: nil
            )
            Auth.auth().signIn(with: firebaseCredential) { [weak self] authResult, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    self?.user = authResult?.user
                }
            }
        }
    }

    // MARK: - Phone (SMS)
    func startPhoneAuth() {
        errorMessage = nil
        let trimmed = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            self.errorMessage = "Enter a valid phone number."
            return
        }
        PhoneAuthProvider.provider().verifyPhoneNumber(trimmed, uiDelegate: nil) { [weak self] verificationID, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.verificationID = verificationID
            }
        }
    }
    
    func verifySMSCode() {
        errorMessage = nil
        guard let verificationID else {
            self.errorMessage = "No verification in progress."
            return
        }
        let code = smsCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else {
            self.errorMessage = "Enter the 6-digit code."
            return
        }
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.user = authResult?.user
            }
        }
    }

    
    // MARK: - Apple nonce helpers
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
    
    /// Generates a random nonce for Apple Sign-In. From Apple sample guidance.
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            var random: UInt8 = 0
            let status = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if status != errSecSuccess { fatalError("Unable to generate nonce. OSStatus \(status)") }
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
        return result
    }
    
    
    // MARK: - Microsoft

    func signInWithMicrosoft() {
        errorMessage = nil
        isLoading = true

        let provider = OAuthProvider(providerID: "microsoft.com")
        provider.customParameters = [
            "prompt": "select_account",
            "tenant": "common" // allows both personal + work/school accounts
        ]
        provider.scopes = ["openid", "email", "profile", "User.Read"]

        provider.getCredentialWith(nil) { [weak self] credential, error in
            guard let self = self else { return }

            // Handle potential errors when fetching the credential
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            // Ensure we received a valid credential from Microsoft
            guard let credential = credential else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Microsoft sign-in failed."
                }
                return
            }

            // Use the credential to sign in with Firebase
            Auth.auth().signIn(with: credential) { authResult, error in
                DispatchQueue.main.async {
                    self.isLoading = false

                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    // Successful sign-in
                    self.user = authResult?.user
                }
            }
        }
    }

}
