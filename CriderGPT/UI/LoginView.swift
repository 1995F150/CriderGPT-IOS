import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var model: AppModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    logoBlock
                    CriderCard(title: "Sign In", subtitle: "Use Supabase Auth with email/password or Google Sign-In") {
                        VStack(spacing: 12) {
                            TextField("Email", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .padding(12)
                                .background(CriderTheme.navy.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(CriderTheme.cream)
                            SecureField("Password", text: $password)
                                .padding(12)
                                .background(CriderTheme.navy.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(CriderTheme.cream)

                            Button {
                                isSubmitting = true
                                Task {
                                    await model.signIn(email: email, password: password)
                                    isSubmitting = false
                                }
                            } label: {
                                if isSubmitting {
                                    ProgressView()
                                } else {
                                    Text("Sign In")
                                }
                            }
                            .buttonStyle(CriderPrimaryButtonStyle())
                            .disabled(isSubmitting || email.isEmpty || password.isEmpty)

                            Button {
                                Task {
                                    await model.signInWithGoogle(anchorProvider: AuthPresentationProvider())
                                }
                            } label: {
                                Text("Continue with Google")
                            }
                            .buttonStyle(CriderSecondaryButtonStyle())
                        }
                    }

                    CriderCard(title: "Backend Status", subtitle: "No fake auth flow, no wrapper, no local-only session") {
                        Text(model.errorMessage ?? "Ready to connect to the live Supabase backend.")
                            .foregroundStyle(CriderTheme.cream)
                            .font(.footnote)
                    }
                }
                .padding(20)
            }
            .safeAreaInset(edge: .top) { Color.clear.frame(height: 4) }
        }
    }

    private var logoBlock: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(CriderTheme.gold.opacity(0.18))
                .frame(width: 86, height: 86)
                .overlay(Text("CG").font(.title.weight(.bold)).foregroundStyle(CriderTheme.gold))
            Text("CriderGPT")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(CriderTheme.cream)
            Text("Native iOS rebuild")
                .foregroundStyle(CriderTheme.goldSoft)
        }
        .padding(.top, 30)
    }
}

final class AuthPresentationProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
    }
}
