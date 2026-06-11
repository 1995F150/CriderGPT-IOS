import SwiftUI

struct ChatScreenView: View {
    @State private var prompt = ""
    @State private var selectedModel = "AGI"
    @State private var messages: [String] = ["Welcome to CriderGPT chat."]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CriderCard(title: "CriderGPT", subtitle: "Chat, voice mode, file uploads, and streaming responses") {
                    HStack {
                        Picker("Model", selection: $selectedModel) {
                            Text("AGI").tag("AGI")
                            Text("Plus").tag("Plus")
                            Text("Pro").tag("Pro")
                        }
                        .pickerStyle(.menu)
                        Spacer()
                        Button("5 Patterns") {}
                    }
                    HStack {
                        Button("AGI") {}
                        Button("New Chat") { messages.removeAll(); messages.append("New conversation started.") }
                        Button("Search chats") {}
                    }
                    .buttonStyle(CriderSecondaryButtonStyle())
                }

                ForEach(messages, id: \.self) { message in
                    CriderCard(title: nil, subtitle: nil) {
                        Text(message)
                            .foregroundStyle(CriderTheme.cream)
                    }
                }
            }
            .padding(16)
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button("Gallery") {}
                Button("Pinned") {}
                Button("Voice") {}
                TextField("Send a message", text: $prompt)
                    .textFieldStyle(.roundedBorder)
                Button("Send") {
                    guard prompt.isEmpty == false else { return }
                    messages.append(prompt)
                    prompt = ""
                }
            }
            .padding(12)
            .background(CriderTheme.navyDeep.opacity(0.96))
        }
    }
}
