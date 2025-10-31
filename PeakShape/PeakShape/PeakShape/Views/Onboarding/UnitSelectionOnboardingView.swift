import SwiftUI

 struct UnitSelectionOnboardingView: View {
    @State private var selectedUnit: UnitSystem = .metric
    
    var onComplete: ((UnitSystem) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("Choose your preferred units")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("You can always change this later in settings")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    ForEach(UnitSystem.allCases, id: \.self) { unit in
                        Button(action: {
                            selectedUnit = unit
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(unit.displayName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(unit.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                if selectedUnit == unit {
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
                                    .fill(selectedUnit == unit ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                    .stroke(selectedUnit == unit ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button("Continue") {
                    onComplete?(selectedUnit)
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
    UnitSelectionOnboardingView { unit in
        print("Unit system selected:", unit.displayName)
    }
}

