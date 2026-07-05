import SwiftUI
import GoogleSignIn

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            ZStack {
                AnixartColor.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(AnixartColor.accent.opacity(0.2))
                            .frame(width: 120, height: 120)
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AnixartColor.accent)
                    }

                    Text("Anixart")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(AnixartColor.textPrimary)

                    Text("Аниме и манга\nв твоём кармане")
                        .font(AnixartFont.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(AnixartColor.textSecondary)

                    Spacer()

                    VStack(spacing: 14) {
                        NavigationLink(destination: SignInView()) {
                            Text("Войти")
                                .font(AnixartFont.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AnixartColor.accent)
                                .cornerRadius(14)
                        }

                        NavigationLink(destination: SignUpView()) {
                            Text("Регистрация")
                                .font(AnixartFont.headline)
                                .foregroundColor(AnixartColor.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(AnixartColor.accent, lineWidth: 1.5)
                                )
                        }
                    }
                    .padding(.horizontal, 32)

                    VStack(spacing: 14) {
                        Text("Или войти через")
                            .font(AnixartFont.caption)
                            .foregroundColor(AnixartColor.textSecondary)

                        HStack(spacing: 20) {
                            SocialLoginButton(systemImage: "globe", color: AnixartColor.blue) {
                                await authManager.signInWithGoogle(presenting: UIApplication.shared.rootViewController ?? UIViewController())
                            }
                            SocialLoginButton(systemImage: "paperplane.fill", color: AnixartColor.accentPurple) {
                                await authManager.signInWithTelegram()
                            }
                            SocialLoginButton(systemImage: "person.circle.fill", color: AnixartColor.blue) {
                                await authManager.signInWithVK()
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct SocialLoginButton: View {
    let systemImage: String
    let color: Color
    let action: () async -> Void

    @State private var isLoading = false

    var body: some View {
        Button {
            isLoading = true
            Task { await action(); isLoading = false }
        } label: {
            if isLoading {
                ProgressView()
                    .tint(AnixartColor.accent)
                    .frame(width: 56, height: 56)
                    .background(AnixartColor.surface)
                    .clipShape(Circle())
            } else {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 56, height: 56)
                    .background(AnixartColor.surface)
                    .clipShape(Circle())
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AnixartTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .textInputAutocapitalization(autocapitalization)
        .disableAutocorrection(true)
        .padding()
        .background(AnixartColor.surface)
        .foregroundColor(AnixartColor.textPrimary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AnixartColor.divider, lineWidth: 1)
        )
    }
}

struct AnixartPrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    let disabled: Bool

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AnixartColor.accent)
                    .cornerRadius(14)
            } else {
                Text(title)
                    .font(AnixartFont.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AnixartColor.accent)
                    .cornerRadius(14)
            }
        }
        .disabled(disabled)
        .buttonStyle(PlainButtonStyle())
    }
}

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var login = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            AnixartColor.background.ignoresSafeArea()

            VStack(spacing: 20) {
                AnixartTextField(placeholder: "Логин или email", text: $login)
                AnixartTextField(placeholder: "Пароль", text: $password, isSecure: true)

                if let error = authManager.error {
                    Text(error)
                        .font(AnixartFont.caption)
                        .foregroundColor(AnixartColor.accent)
                        .multilineTextAlignment(.center)
                }

                AnixartPrimaryButton(
                    title: "Войти",
                    isLoading: authManager.isLoading,
                    action: { Task { await authManager.signIn(login: login, password: password) } },
                    disabled: login.isEmpty || password.isEmpty || authManager.isLoading
                )

                NavigationLink(destination: RestoreView()) {
                    Text("Забыли пароль?")
                        .font(AnixartFont.caption)
                        .foregroundColor(AnixartColor.textSecondary)
                }
            }
            .padding(32)
        }
        .navigationTitle("Вход")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var login = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            AnixartColor.background.ignoresSafeArea()

            VStack(spacing: 20) {
                AnixartTextField(placeholder: "Логин", text: $login)
                AnixartTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                AnixartTextField(placeholder: "Пароль", text: $password, isSecure: true)

                if let error = authManager.error {
                    Text(error)
                        .font(AnixartFont.caption)
                        .foregroundColor(AnixartColor.accent)
                        .multilineTextAlignment(.center)
                }

                AnixartPrimaryButton(
                    title: "Зарегистрироваться",
                    isLoading: authManager.isLoading,
                    action: { Task { await authManager.signUp(login: login, email: email, password: password) } },
                    disabled: login.isEmpty || email.isEmpty || password.isEmpty || authManager.isLoading
                )

                NavigationLink(destination: VerifyView()) {
                    Text("Ввести код подтверждения")
                        .font(AnixartFont.caption)
                        .foregroundColor(AnixartColor.textSecondary)
                }
            }
            .padding(32)
        }
        .navigationTitle("Регистрация")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct VerifyView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var code = ""

    var body: some View {
        ZStack {
            AnixartColor.background.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Введите код подтверждения,\nотправленный на вашу почту")
                    .font(AnixartFont.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AnixartColor.textSecondary)

                AnixartTextField(placeholder: "Код", text: $code, keyboardType: .numberPad)

                if let error = authManager.error {
                    Text(error)
                        .font(AnixartFont.caption)
                        .foregroundColor(AnixartColor.accent)
                        .multilineTextAlignment(.center)
                }

                AnixartPrimaryButton(
                    title: "Подтвердить",
                    isLoading: authManager.isLoading,
                    action: { Task { await authManager.verify(code: code) } },
                    disabled: code.isEmpty || authManager.isLoading
                )
            }
            .padding(32)
        }
        .navigationTitle("Подтверждение")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct RestoreView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var login = ""

    var body: some View {
        ZStack {
            AnixartColor.background.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Введите ваш логин или email\nдля восстановления пароля")
                    .font(AnixartFont.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AnixartColor.textSecondary)

                AnixartTextField(placeholder: "Логин или email", text: $login)

                if let error = authManager.error {
                    Text(error)
                        .font(AnixartFont.caption)
                        .foregroundColor(AnixartColor.accent)
                        .multilineTextAlignment(.center)
                }

                AnixartPrimaryButton(
                    title: "Восстановить",
                    isLoading: authManager.isLoading,
                    action: { Task { await authManager.restore(login: login) } },
                    disabled: login.isEmpty || authManager.isLoading
                )
            }
            .padding(32)
        }
        .navigationTitle("Восстановление")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
