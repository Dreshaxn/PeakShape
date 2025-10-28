import SwiftUI

struct GoalWeightOnboardingView: View {
    @State private var goalWeightText: String = ""
    @State private var showValidation: Bool = false
    
    let currentWeight: Double
    
    var onComplete: ((Double) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("What's your goal weight?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Current weight: \(String(format: "%.1f", currentWeight)) kg")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 20) {
                    TextField("Goal weight", text: $goalWeightText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .font(.title2)
                        .padding(.horizontal)
                        .onChange(of: goalWeightText) { newValue in
                            goalWeightText = filterDecimalInput(newValue)
                        }
                        .overlay(alignment: .trailing) {
                            Text("kg")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)
                        }
                    
                    if showValidation, let message = validationMessage {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                Button("Continue") {
                    if let goalWeight = Double(goalWeightText), isValid {
                        onComplete?(goalWeight)
                    } else {
                        withAnimation { showValidation = true }
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!isValid)
                .padding(.horizontal)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Validation
private extension GoalWeightOnboardingView {
    var isValid: Bool {
        guard let goalWeight = Double(goalWeightText) else { return false }
        return goalWeight > 25 && goalWeight < 400
    }
    
    var validationMessage: String? {
        if goalWeightText.isEmpty {
            return "Please enter your goal weight."
        }
        guard let goalWeight = Double(goalWeightText) else {
            return "Please enter a valid weight."
        }
        if goalWeight <= 25 || goalWeight >= 400 {
            return "Please enter a goal weight between 25-400 kg."
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
    GoalWeightOnboardingView(currentWeight: 70.0) { goalWeight in
        print("Goal weight entered:", goalWeight)
    }
}
