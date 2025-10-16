import Foundation
import FirebaseAuth
import Combine

// This ViewModel manages authentication state and actions for the app.
class AuthViewModel: ObservableObject {
    // The current Firebase user (nil if not logged in)
    @Published var user: User?
    // Any error message to show in the UI
    @Published var errorMessage: String?
    // Listener for auth state changes
    private var handle: AuthStateDidChangeListenerHandle?
    
    // Set up the listener when the ViewModel is created
    init() {
        // Listen for changes in authentication state
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user // Update the user property
        }
    }
    
    // Remove the listener when the ViewModel is destroyed
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // Log in with email and password
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
    
    // Register a new user with email and password
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
    
    // Sign out the current user
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil // Clear the user
        } catch {
            // If there's an error signing out, show it
            self.errorMessage = error.localizedDescription
        }
    }
} 