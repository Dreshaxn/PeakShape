import SwiftUI

struct AuthGateView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.user != nil {
                HomeView()
            } else {
                LoginView()
            }
        }
    }
}
