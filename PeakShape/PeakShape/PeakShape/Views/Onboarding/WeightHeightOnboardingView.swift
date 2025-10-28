import SwiftUI

struct WeightHeightOnboardingView: View {
    @State private var heightText: String = ""
    @State private var weightText: String = ""
    @State private var showValidation: Bool = false
    
    var onComplete: ((Double, Double) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("What's your height and weight?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us calculate your BMI and nutritional needs")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        TextField("Height", text: $heightText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .onChange(of: heightText) { newValue in
                                heightText = filterDecimalInput(newValue)
                            }
                            .overlay(alignment: .trailing) {
                                Text("cm")
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 8)
                            }
                        
                        TextField("Weight", text: $weightText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .onChange(of: weightText) { newValue in
                                weightText = filterDecimalInput(newValue)
                            }
                            .overlay(alignment: .trailing) {
                                Text("kg")
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 8)
                            }
                    }
                    .padding(.horizontal)
                    
                    if showValidation, let message = validationMessage {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                Button("Continue") {
                    if let height = Double(heightText), let weight = Double(weightText), isValid {
                        onComplete?(height, weight)
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
private extension WeightHeightOnboardingView {
    var isValid: Bool {
        guard let height = Double(heightText), let weight = Double(weightText) else { return false }
        return height > 80 && height < 250 && weight > 25 && weight < 400
    }
    
    var validationMessage: String? {
        if heightText.isEmpty || weightText.isEmpty {
            return "Please enter both height and weight."
        }
        guard let height = Double(heightText) else {
            return "Please enter a valid height."
        }
        guard let weight = Double(weightText) else {
            return "Please enter a valid weight."
        }
        if height <= 80 || height >= 250 {
            return "Please enter a height between 80-250 cm."
        }
        if weight <= 25 || weight >= 400 {
            return "Please enter a weight between 25-400 kg."
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
    WeightHeightOnboardingView { height, weight in
        print("Height: \(height) cm, Weight: \(weight) kg")
    }
}
