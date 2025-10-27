import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

// ViewModel manages authentication state and actions for the app.
class AuthViewModel: ObservableObject {
    // The current Firebase user (nil if not logged in)
    @Published var user: FirebaseAuth.User?
    // Any error message to show in the UI
    @Published var errorMessage: String?
    // Listener for auth state changes
    private var handle: AuthStateDidChangeListenerHandle?
    // Firestore reference
    private let db = Firestore.firestore()
    
    // Set up the listener when the ViewModel is created
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    // Remove the listener when the ViewModel is destroyed
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) {
        errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.user = result?.user
                }
            }
        }
    }
    
    func register(email: String, password: String) {
        errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.user = result?.user
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    struct UserOnboardingData: Codable {
        var age: Int
        var gender: String
        var heightCm: Double
        var weightKg: Double
        var activityLevel: String
        var dietaryPreference: String
        var goal: String
        var dailyCalories: Double
        var macros: [String: Double]
    }
    // MARK: - Save Onboarding Data
    
    func saveOnboardingData(_ data: UserOnboardingData, completion: @escaping (Error?) -> Void) {
        guard let uid = user?.uid else {
            completion(NSError(domain: "AuthError", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not authenticated"
            ]))
            return
        }
        
        do {
            let encodedData = try Firestore.Encoder().encode(data)
            db.collection("users").document(uid).setData(encodedData, merge: true) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
}
