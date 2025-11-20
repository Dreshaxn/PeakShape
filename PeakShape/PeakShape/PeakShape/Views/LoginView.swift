import SwiftUI
import UIKit
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices


struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    // Helper to grab a presenter for Google
    private func presenter() -> UIViewController {
        // Find the top-most key window's root VC
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.compactMap { $0 as? UIWindowScene }
        let windows = windowScenes.flatMap { $0.windows }
        return windows.first(where: { $0.isKeyWindow })?.rootViewController ?? UIViewController()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Spacer(minLength: 30)
                
                Text("Welcome to PeakShape")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)

                // MARK: - Email/Password
                VStack(spacing: 10) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding(.horizontal)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    Button("Login with Email") {
                        authViewModel.login(email: email, password: password)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .buttonStyle(.borderedProminent)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                }
                                
                // MARK: - Divider
                HStack {
                    Rectangle().frame(height: 1).opacity(0.2)
                    Text("or").foregroundStyle(.secondary)
                    Rectangle().frame(height: 1).opacity(0.2)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // MARK: - Apple Sign In
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        authViewModel.makeAppleIDRequest(request)
                    },
                    onCompletion: { result in
                        authViewModel.handleAppleSignIn(result: result)
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                
                // MARK: - Google Sign In
                
                GoogleSignInButton(
                    viewModel: GoogleSignInButtonViewModel(
                        scheme: .dark,
                        style: .wide,
                        state: .normal
                    ),
                    action: {
                        authViewModel.signInWithGoogle(presenting: presenter())
                    }
                )
                .frame(height: 44)                 // match Apple height
                .padding(.horizontal)

                // MARK: - Microsoft Sign In
                Button(action: {
                    authViewModel.signInWithMicrosoft()
                }) {
                    HStack(spacing: 10) {
                        Image("ms_box_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20) // smaller logo for visual balance
                        Text("Sign in with Microsoft")
                            .font(.subheadline)           // slightly smaller font
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)               // slightly less padding
                    .background(Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)

                
                // MARK: - Phone Sign-In (Compact)(temporarily not in use)
              /*  VStack(spacing: 8) {
                    Text("Phone Sign-In")
                        .font(.headline)
                    TextField("+1 555 555 1234", text: $authViewModel.phoneNumber)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                        .padding(.horizontal)
                    
                    HStack {
                        Button("Send code") { authViewModel.startPhoneAuth() }
                            .buttonStyle(.bordered)
                        if authViewModel.verificationID != nil {
                            SecureField("6-digit code", text: $authViewModel.smsCode)
                                .textFieldStyle(.roundedBorder)
                            Button("Verify") { authViewModel.verifySMSCode() }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.horizontal)
                }*/
                
                // MARK: - Error message
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .font(.subheadline)
                }
                
                NavigationLink("Need an account? Register", destination: RegisterView())
                    .padding(.top, 6)
                
                Spacer(minLength: 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}


#if DEBUG
/// A lightweight mock AuthViewModel so the preview compiles without Firebase or live auth.
final class AuthViewModelPreviewMock: AuthViewModel {
    override init() {
        super.init()
        // optional: preload fake data
        self.phoneNumber = "+1 555 555 5555"
        self.errorMessage = nil
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModelPreviewMock())
    }
}
#endif
