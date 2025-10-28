import SwiftUI

struct ActivityLevelOnboardingView: View {
    @State private var selectedActivity: UserActivityLevel = .moderate
    
    var onComplete: ((UserActivityLevel) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("What's your activity level?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us calculate your daily calorie needs")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    ForEach(UserActivityLevel.allCases, id: \.self) { activity in
                        Button(action: {
                            selectedActivity = activity
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(activity.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(activity.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                if selectedActivity == activity {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.secondary)
                                        .font(.title2)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedActivity == activity ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                    .stroke(selectedActivity == activity ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button("Continue") {
                    onComplete?(selectedActivity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview
#Preview {
    ActivityLevelOnboardingView { activity in
        print("Activity level selected:", activity.title)
    }
}
