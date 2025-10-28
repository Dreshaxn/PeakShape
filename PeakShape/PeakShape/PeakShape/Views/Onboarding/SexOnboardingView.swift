import SwiftUI

struct SexOnboardingView: View {
    @State private var selectedSex: Sex = .male
    
    var onComplete: ((Sex) -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text("What's your sex?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us calculate your nutritional needs accurately")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    ForEach(Sex.allCases, id: \.self) { sex in
                        Button(action: {
                            selectedSex = sex
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(sex.displayName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                if selectedSex == sex {
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
                                    .fill(selectedSex == sex ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                    .stroke(selectedSex == sex ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button("Continue") {
                    onComplete?(selectedSex)
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
    SexOnboardingView { sex in
        print("Sex selected:", sex.displayName)
    }
}
