import SwiftUI

struct BlueprintGeneratorView: View {
    @State private var mission: String = ""
    @State private var isGenerating: Bool = false
    @State private var generatedPlan: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Blueprint Generator")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("What's the mission?")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $mission)
                        .frame(height: 150)
                        .padding(4)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2)))
                    
                    if mission.isEmpty {
                        Text("e.g., 'Research best cattle feed ratios for show steers and create a 30-day plan'")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                            .allowsHitTesting(false)
                    }
                }
                
                Button(action: generateBlueprint) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 5)
                        }
                        Text(isGenerating ? "Generating..." : "Generate Blueprint")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(mission.isEmpty || isGenerating ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(mission.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
                
                if let plan = generatedPlan {
                    VStack(alignment: .leading, spacing: 15) {
                        Divider()
                            .padding(.vertical)
                        
                        Text("Generated Blueprint")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(plan)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Generator")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func generateBlueprint() {
        withAnimation {
            isGenerating = true
        }
        
        // Simulate backend generation logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.generatedPlan = \"\"\"
                📋 Mission: \\(mission)
                
                Phase 1: Analysis (Week 1)
                • Data collection and baseline establishment.
                • Risk assessment and resource allocation.
                
                Phase 2: Strategy (Week 2)
                • Defining milestones and success metrics.
                • Drafting operational procedures.
                
                Phase 3: Implementation (Weeks 3-4)
                • Execution of optimized workflows.
                • Continuous monitoring and feedback loops.
                \"\"\"
                self.isGenerating = false
            }
        }
    }
}

#Preview {
    NavigationView {
        BlueprintGeneratorView()
    }
}
