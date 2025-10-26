import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                Button("Login") {
                    authViewModel.login(email: email, password: password)
                }

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                NavigationLink("Bro, Make an account", destination: RegisterView())
            }
            .padding()
        }
    }
}
