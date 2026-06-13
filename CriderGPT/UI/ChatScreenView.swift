import SwiftUI

struct ChatScreenView: View {
    @State private var prompt = ""
    @State private var selectedModel = "AGI"
    @State private var messages: [ChatMessage] = [
        ChatMessage(role: .assistant, content: "Welcome to CriderGPT chat.")
    ]
    @State private var isStreaming = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(messages) { message in
                        ChatBubbleView(message: message)
                    }
                }
                .padding()
            }
            
            Divider()
            
            HStack {
                TextField("Send a message", text: $prompt)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isStreaming)
                
                Button(action: sendMessage) {
                    if isStreaming {
                        ProgressView()
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .disabled(prompt.isEmpty || isStreaming)
            }
            .padding()
        }
        .navigationTitle("Chat")
    }

    func sendMessage() {
        let userMessage = ChatMessage(role: .user, content: prompt)
        messages.append(userMessage)
        let currentPrompt = prompt
        prompt = ""
        isStreaming = true
        
        let assistantMessage = ChatMessage(role: .assistant, content: "")
        messages.append(assistantMessage)
        let assistantIndex = messages.count - 1
        
        Task {
            do {
                // Native Streaming for Supabase Edge Functions
                let baseURL = "https://your-project"
                let functionPath = ".functions.supabase.co/chat"
                guard let url = URL(string: baseURL + functionPath) else { return }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let body: [String: Any] = ["prompt": currentPrompt, "model": selectedModel]
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                
                let (bytes, response) = try await URLSession.shared.bytes(for: request)
                
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    await MainActor.run { messages[assistantIndex].content = "Error connecting to service." }
                    isStreaming = false
                    return
                }
                
                for try await line in bytes.lines {
                    if let data = line.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let chunk = json["text"] as? String {
                        await MainActor.run {
                            messages[assistantIndex].content += chunk
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    messages[assistantIndex].content = "Error: \(error.localizedDescription)"
                }
            }
            isStreaming = false
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: ChatRole
    var content: String
}

enum ChatRole {
    case user, assistant
}

struct ChatBubbleView: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.role == .user { Spacer() }
            Text(message.content)
                .padding()
                .background(message.role == .user ? Color.blue : Color(.secondarySystemBackground))
                .foregroundColor(message.role == .user ? .white : .primary)
                .cornerRadius(10)
            if message.role == .assistant { Spacer() }
        }
    }
}
