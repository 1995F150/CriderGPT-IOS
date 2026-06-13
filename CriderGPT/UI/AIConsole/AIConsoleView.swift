import SwiftUI

struct AIConsoleView: View {
    @State private var logs: [ConsoleLog] = [
        ConsoleLog(message: "Initializing AI subsystems...", type: .info),
        ConsoleLog(message: "Connected to Supabase Edge Functions.", type: .success),
        ConsoleLog(message: "Awaiting user input...", type: .info)
    ]
    
    struct ConsoleLog: Identifiable {
        let id = UUID()
        let timestamp = Date()
        let message: String
        let type: LogType
    }
    
    enum LogType {
        case info, success, warning, error
        
        var color: Color {
            switch self {
            case .info: return .blue
            case .success: return .green
            case .warning: return .orange
            case .error: return .red
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(logs) { log in
                        HStack(alignment: .top) {
                            Text(log.timestamp, style: .time)
                                .font(.caption2.monospaced())
                                .foregroundColor(.secondary)
                            
                            Text(log.message)
                                .font(.caption.monospaced())
                                .foregroundColor(log.type.color)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.black.opacity(0.05))
            
            Divider()
            
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("AI Engine Online")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    logs.append(ConsoleLog(message: "Manual log refresh requested.", type: .info))
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
            }
            .padding()
        }
        .navigationTitle("AI Console")
    }
}

#Preview {
    NavigationView {
        AIConsoleView()
    }
}
