import SwiftUI

struct OnboardingView: View {
    // MARK: - Input State
    @State private var sex: Sex = .male
    @State private var name: String = ""
    @State private var ageText: String = ""
    @State private var heightText: String = ""
    @State private var weightText: String = ""
    
    // MARK: - UI State
    @State private var showValidation: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Output
    // Your teammate can hook this up to storage later.
    // Units: leave as entered; you can decide to treat height as cm and weight as kg,
    // or convert in the onComplete handler.
    var onComplete: ((CollectedProfile) -> Void)?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Info")) {
                    Picker("Sex", selection: $sex) {
                        ForEach(Sex.allCases, id: \.self) { value in
                            Text(value.displayName).tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                    
                    TextField("Age (years)", text: $ageText)
                        .keyboardType(.numberPad)
                        .onChange(of: ageText) { newValue in
                            ageText = newValue.filter { $0.isNumber }
                        }
                }
                
                Section(header: Text("Body Metrics")) {
                    TextField("Height", text: $heightText)
                        .keyboardType(.decimalPad)
                        .onChange(of: heightText) { newValue in
                            heightText = filterDecimalInput(newValue)
                        }
                        .overlay(alignment: .trailing) {
                            Text("cm")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)
                        }
                    
                    TextField("Weight", text: $weightText)
                        .keyboardType(.decimalPad)
                        .onChange(of: weightText) { newValue in
                            weightText = filterDecimalInput(newValue)
                        }
                        .overlay(alignment: .trailing) {
                            Text("kg")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)
                        }
                }
                
                if showValidation, let message = validationMessage {
                    Section {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Tell us about you")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Continue") {
                        if let profile = buildProfileIfValid() {
                            onComplete?(profile)
                            dismiss()
                        } else {
                            withAnimation { showValidation = true }
                        }
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

// MARK: - Types
extension OnboardingView {
    enum Sex: String, CaseIterable {
        case male, female
        
        var displayName: String {
            switch self {
            case .male: return "Male"
            case .female: return "Female"
            }
        }
    }
    
    struct CollectedProfile {
        let name: String
        let sex: Sex
        let age: Int
        let height: Double   // as entered; treat as cm by convention
        let weight: Double   // as entered; treat as kg by convention
    }
}

// MARK: - Validation
private extension OnboardingView {
    var isValid: Bool {
        buildProfileIfValid() != nil
    }
    
    var validationMessage: String? {
        // Return a helpful message for the first failing rule
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Please enter your name."
        }
        guard let age = Int(ageText), (13...120).contains(age) else {
            return "Please enter a valid age between 13 and 120."
        }
        guard let height = Double(heightText), height > 80, height < 250 else {
            return "Please enter a valid height in centimeters (e.g., 175)."
        }
        guard let weight = Double(weightText), weight > 25, weight < 400 else {
            return "Please enter a valid weight in kilograms (e.g., 70)."
        }
        return nil
    }
    
    func buildProfileIfValid() -> CollectedProfile? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return nil }
        guard let age = Int(ageText), (13...120).contains(age) else { return nil }
        guard let height = Double(heightText), height > 80, height < 250 else { return nil }
        guard let weight = Double(weightText), weight > 25, weight < 400 else { return nil }
        
        return CollectedProfile(
            name: trimmedName,
            sex: sex,
            age: age,
            height: height,
            weight: weight
        )
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
    OnboardingView { profile in
        print("Collected profile:", profile)
    }
}
