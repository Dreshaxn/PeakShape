import SwiftUI

struct AuthGateView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var firestoreViewModel = FirestoreViewModel()

    var body: some View {
        Group {
            if authViewModel.user != nil {
                // Check if user has completed onboarding
                if firestoreViewModel.hasCompletedOnboarding {
                    HomeView()
                        .environmentObject(firestoreViewModel)
                } else {
                    // Show onboarding for new users
                    OnboardingView { profile in
                        // Save profile to Firestore and mark onboarding complete
                        if let userId = authViewModel.user?.uid {
                            firestoreViewModel.saveUserProfile(profile, userId: userId)
                            authViewModel.completeOnboarding()
                        }
                    }
                    .environmentObject(firestoreViewModel)
                }
            } else {
                LoginView()
            }
        }
    }
}
