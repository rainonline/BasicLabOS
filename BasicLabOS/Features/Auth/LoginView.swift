import SwiftUI

struct LoginView: View {
    @Environment(AuthSessionStore.self) private var authStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.accentColor.opacity(0.18),
                        Color(.systemBackground),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "cube.transparent")
                            .font(.system(size: 44))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.accentColor)
                        Text("BasicLab OS")
                            .font(.largeTitle.weight(.bold))
                        Text("登录以查看自营商品")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 8)

                    VStack(spacing: 14) {
                        TextField("用户名", text: $username)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        SecureField("密码", text: $password)
                            .textContentType(.password)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            Task {
                                await submit()
                            }
                        } label: {
                            Group {
                                if isSubmitting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("登录")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .buttonStyle(.glassProminent)
                        .disabled(isSubmitting || username.isEmpty || password.isEmpty)
                    }
                    .frame(maxWidth: horizontalSizeClass == .regular ? 420 : .infinity)
                }
                .padding(24)
            }
        }
    }

    private func submit() async {
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            try await authStore.login(username: username, password: password)
        } catch {
            errorMessage = APIErrorMessage.message(for: error)
        }
    }
}
