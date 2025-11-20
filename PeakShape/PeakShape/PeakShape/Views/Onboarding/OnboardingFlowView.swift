import SwiftUI

struct OnboardingFlowView: View {
    @State private var currentStep = 0
    @State private var collectedData = OnboardingData()
    @Environment(\.dismiss) private var dismiss
    
    var onComplete: ((UserProfile) -> Void)?
    
    private let totalSteps = 7
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Progress indicator
                VStack {
                    HStack {
                        ForEach(0..<totalSteps, id: \.self) { step in
                            Circle()
                                .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                
                // Current step content
                Group {
                    switch currentStep {
                    case 0:
                        NameOnboardingView { name in
                            collectedData.name = name
                            nextStep()
                        }
                    case 1:
                        SexOnboardingView { sex in
                            collectedData.sex = sex
                            nextStep()
                        }
                    case 2:
                        AgeOnboardingView { age in
                            collectedData.age = age
                            nextStep()
                        }
                    case 3:
                        WeightHeightOnboardingView { height, weight in
                            collectedData.height = height
                            collectedData.weight = weight
                            nextStep()
                        }
                    case 4:
                        ActivityLevelOnboardingView { activityLevel in
                            collectedData.activityLevel = activityLevel
                            nextStep()
                        }
                    case 5:
                        GoalWeightOnboardingView(currentWeight: collectedData.weight) { goalWeight in
                            collectedData.goalWeight = goalWeight
                            nextStep()
                        }
                    case 6:
                        WeightChangeOnboardingView(
                            currentWeight: collectedData.weight,
                            goalWeight: collectedData.goalWeight
                        ) { weightGoal, weeklyChange in
                            collectedData.weightGoal = weightGoal
                            collectedData.weeklyWeightChange = weeklyChange
                            completeOnboarding()
                        }
                    default:
                        EmptyView()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    // increments to show the next page
    private func nextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep += 1
        }
    }
    
    private func completeOnboarding() {
        let userProfile = UserProfile(
            name: collectedData.name,
            sex: collectedData.sex,
            age: collectedData.age,
            height: collectedData.height,
            weight: collectedData.weight,
            activityLevel: collectedData.activityLevel,
            goalWeight: collectedData.goalWeight,
            weightGoal: collectedData.weightGoal,
            weeklyWeightChange: collectedData.weeklyWeightChange
        )
        
        onComplete?(userProfile)
        dismiss()
    }
}

// MARK: - Onboarding Data Container
private struct OnboardingData {
    var name: String = ""
    var sex: Sex = .male
    var age: Int = 0
    var height: Double = 0
    var weight: Double = 0
    var activityLevel: UserActivityLevel = .moderate
    var goalWeight: Double = 0
    var weightGoal: UserWeightGoal = .maintain
    var weeklyWeightChange: Double? = nil
}

// MARK: - Preview
#Preview {
    OnboardingFlowView { profile in
        print("Onboarding completed with profile:", profile)
    }
}
