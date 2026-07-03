import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 72))
                    .foregroundColor(.accentColor)

                Text("Anixart")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Аниме и манга\nв твоём кармане")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                Spacer()

                VStack(spacing: 12) {
                    NavigationLink(destination: SignInView()) {
                        Text("Войти")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }

                    NavigationLink(destination: SignUpView()) {
                        Text("Регистрация")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.accentColor, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 32)

                VStack(spacing: 12) {
                    Text("Или войти через")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 20) {
                        SocialLoginButton(systemImage: "globe", color: .blue) {
                            await authManager.signInWithGoogle(presenting: UIApplication.shared.rootViewController ?? UIViewController())
                        }
                        SocialLoginButton(systemImage: "paperplane.fill", color: .cyan) {
                            await authManager.signInWithTelegram()
                        }
                        SocialLoginButton(systemImage: "person.circle.fill", color: .blue) {
                            await authManager.signInWithVK()
                        }
                    }
                }
                .padding(.bottom, 40)
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
                    .frame(width: 52, height: 52)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            } else {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 52, height: 52)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
    }
}

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var login = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Логин или email", text: $login)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            SecureField("Пароль", text: $password)
                .textFieldStyle(.roundedBorder)

            if let error = authManager.error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Button {
                Task { await authManager.signIn(login: login, password: password) }
            } label: {
                if authManager.isLoading {
                    ProgressView().tint(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color.accentColor).cornerRadius(12)
                } else {
                    Text("Войти")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color.accentColor).cornerRadius(12)
                }
            }
            .disabled(login.isEmpty || password.isEmpty || authManager.isLoading)

            NavigationLink(destination: RestoreView()) {
                Text("Забыли пароль?")
                    .font(.subheadline)
            }
        }
        .padding(32)
        .navigationTitle("Вход")
    }
}

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var login = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Логин", text: $login)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Пароль", text: $password)
                .textFieldStyle(.roundedBorder)

            if let error = authManager.error {
                Text(error).font(.caption).foregroundColor(.red)
            }

            Button {
                Task { await authManager.signUp(login: login, email: email, password: password) }
            } label: {
                if authManager.isLoading {
                    ProgressView().tint(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color.accentColor).cornerRadius(12)
                } else {
                    Text("Зарегистрироваться")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color.accentColor).cornerRadius(12)
                }
            }
            .disabled(login.isEmpty || email.isEmpty || password.isEmpty || authManager.isLoading)

            NavigationLink(destination: VerifyView()) {
                Text("Ввести код подтверждения")
                    .font(.subheadline)
            }
        }
        .padding(32)
        .navigationTitle("Регистрация")
    }
}

struct VerifyView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var code = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Введите код подтверждения,\nотправленный на вашу почту")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            TextField("Код", text: $code)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)

            if let error = authManager.error {
                Text(error).font(.caption).foregroundColor(.red)
            }

            Button {
                Task { await authManager.verify(code: code) }
            } label: {
                if authManager.isLoading {
                    ProgressView().tint(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color.accentColor).cornerRadius(12)
                } else {
                    Text("Подтвердить")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color.accentColor).cornerRadius(12)
                }
            }
            .disabled(code.isEmpty || authManager.isLoading)
        }
        .padding(32)
        .navigationTitle("Подтверждение")
    }
}

struct RestoreView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var login = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Введите ваш логин или email\nдля восстановления пароля")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            TextField("Логин или email", text: $login)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

            if let error = authManager.error {
                Text(error).font(.caption).foregroundColor(.red)
            }

            Button {
                Task { await authManager.restore(login: login) }
            } label: {
                if authManager.isLoading {
                    ProgressView().tint(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color.accentColor).cornerRadius(12)
                } else {
                    Text("Восстановить")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color.accentColor).cornerRadius(12)
                }
            }
            .disabled(login.isEmpty || authManager.isLoading)
        }
        .padding(32)
        .navigationTitle("Восстановление")
    }
}
