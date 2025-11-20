import SwiftUI

struct NameOnboardingView: View {
    @State private var name: String = ""
    @State private var showValidation: Bool = false
    
    var onComplete: ((String) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("What's your name?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("We'll use this to personalize your experience")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 20) {
                    TextField("Enter your name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .font(.title2)
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
                    if isValid {
                        onComplete?(name.trimmingCharacters(in: .whitespacesAndNewlines))
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
private extension NameOnboardingView {
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var validationMessage: String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Please enter your name."
        }
        return nil
    }
}

// MARK: - Preview
#Preview {
    NameOnboardingView { name in
        print("Name entered:", name)
    }
}
