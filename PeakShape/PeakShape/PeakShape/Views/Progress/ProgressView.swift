import SwiftUI
struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(1.4)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).opacity(0.9))
    }
}
