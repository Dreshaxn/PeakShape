import SwiftUI

struct WeightChangeOnboardingView: View {
    @State private var selectedGoal: UserWeightGoal = .maintain
    @State private var weeklyChangeText: String = ""
    @State private var showValidation: Bool = false
    
    let currentWeight: Double
    let goalWeight: Double
    
    var onComplete: ((UserWeightGoal, Double?) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("How do you want to reach your goal?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Choose your approach to reaching your goal weight")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    ForEach(UserWeightGoal.allCases, id: \.self) { goal in
                        Button(action: {
                            selectedGoal = goal
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(goal.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(goal.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                if selectedGoal == goal {
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
                                    .fill(selectedGoal == goal ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                    .stroke(selectedGoal == goal ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                // Show weekly change input only if not maintaining weight
                if selectedGoal != .maintain {
                    VStack(spacing: 12) {
                        Text("How many pounds per week?")
                            .font(.headline)
                            .padding(.top)
                        
                        TextField("Weekly change", text: $weeklyChangeText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .onChange(of: weeklyChangeText) { newValue in
                                weeklyChangeText = filterDecimalInput(newValue)
                            }
                            .overlay(alignment: .trailing) {
                                Text("lbs/week")
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 8)
                            }
                        
                        if showValidation, let message = validationMessage {
                            Text(message)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button("Continue") {
                    if selectedGoal == .maintain || isValid {
                        let weeklyChange = selectedGoal == .maintain ? nil : Double(weeklyChangeText)
                        onComplete?(selectedGoal, weeklyChange)
                    } else {
                        withAnimation { showValidation = true }
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(selectedGoal != .maintain && !isValid)
                .padding(.horizontal)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Validation
private extension WeightChangeOnboardingView {
    var isValid: Bool {
        guard let weeklyChange = Double(weeklyChangeText) else { return false }
        return weeklyChange > 0 && weeklyChange <= 2.0
    }
    
    var validationMessage: String? {
        if weeklyChangeText.isEmpty {
            return "Please enter your weekly weight change goal."
        }
        guard let weeklyChange = Double(weeklyChangeText) else {
            return "Please enter a valid number."
        }
        if weeklyChange <= 0 {
            return "Please enter a positive number."
        }
        if weeklyChange > 2.0 {
            return "Please enter a realistic goal (max 2 lbs/week)."
        }
        return nil
    }
    
    func filterDecimalInput(_ input: String) -> String {
        // Allow digits and at most one decimal separator
        var result = ""
        var hasDecimal = false
        for ch in input {
            if ch.isNumber {
                result.append(ch)
            } else if (ch == "." || ch == ",") && !hasDecimal {
                result.append(".")
                hasDecimal = true
            }
        }
        return result
    }
}

// MARK: - Preview
#Preview {
    WeightChangeOnboardingView(currentWeight: 70.0, goalWeight: 65.0) { goal, weeklyChange in
        print("Goal: \(goal.title), Weekly change: \(weeklyChange ?? 0)")
    }
}
