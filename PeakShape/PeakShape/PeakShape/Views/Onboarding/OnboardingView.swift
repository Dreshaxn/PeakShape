import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Output
    // Updated to use the new UserProfile model
    var onComplete: ((UserProfile) -> Void)?
    
    var body: some View {
        OnboardingFlowView { profile in
            onComplete?(profile)
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView { profile in
        print("Onboarding completed with profile:", profile)
    }
}
