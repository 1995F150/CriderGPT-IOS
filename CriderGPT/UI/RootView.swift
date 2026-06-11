import SwiftUI

struct RootView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack {
            CriderTheme.navyDeep.ignoresSafeArea()
            backgroundDecor

            Group {
                if model.isLoading {
                    LoadingView()
                } else if model.isAuthenticated {
                    AuthenticatedShellView()
                } else {
                    LoginView()
                }
            }
        }
        .tint(CriderTheme.gold)
        .alert("CriderGPT", isPresented: Binding(get: { model.errorMessage != nil }, set: { if !$0 { model.errorMessage = nil } })) {
            Button("OK", role: .cancel) { model.errorMessage = nil }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }

    private var backgroundDecor: some View {
        ZStack {
            LinearGradient(colors: [CriderTheme.navyDeep, CriderTheme.navy], startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle()
                .fill(CriderTheme.gold.opacity(0.08))
                .frame(width: 280, height: 280)
                .blur(radius: 20)
                .offset(x: 130, y: -260)
            RoundedRectangle(cornerRadius: 80, style: .continuous)
                .fill(CriderTheme.borderBlue.opacity(0.12))
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(24))
                .offset(x: -140, y: 300)
        }
        .ignoresSafeArea()
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(CriderTheme.gold)
            Text("Loading CriderGPT")
                .foregroundStyle(CriderTheme.cream)
        }
        .padding(28)
        .background(CriderTheme.card.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
