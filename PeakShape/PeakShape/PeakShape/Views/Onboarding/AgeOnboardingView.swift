import SwiftUI

struct AgeOnboardingView: View {
    @State private var ageText: String = ""
    @State private var showValidation: Bool = false
    
    var onComplete: ((Int) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("How old are you?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us calculate your nutritional needs")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 20) {
                    TextField("Enter your age", text: $ageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .font(.title2)
                        .padding(.horizontal)
                        .onChange(of: ageText) { newValue in
                            ageText = newValue.filter { $0.isNumber }
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
                    if let age = Int(ageText), isValid {
                        onComplete?(age)
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
private extension AgeOnboardingView {
    var isValid: Bool {
        guard let age = Int(ageText) else { return false }
        return (13...120).contains(age)
    }
    
    var validationMessage: String? {
        if ageText.isEmpty {
            return "Please enter your age."
        }
        guard let age = Int(ageText) else {
            return "Please enter a valid age."
        }
        if !(13...120).contains(age) {
            return "Please enter an age between 13 and 120."
        }
        return nil
    }
}

// MARK: - Preview
#Preview {
    AgeOnboardingView { age in
        print("Age entered:", age)
    }
}
