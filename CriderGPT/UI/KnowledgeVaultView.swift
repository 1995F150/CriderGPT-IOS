import SwiftUI

struct KnowledgeVaultView: View {
    @State private var searchText = ""
    
    struct KnowledgeArticle: Identifiable {
        let id = UUID()
        let title: String
        let category: String
    }
    
    let articles = [
        KnowledgeArticle(title: "Farm Management Basics", category: "Operations"),
        KnowledgeArticle(title: "Supabase Integration Guide", category: "Technical"),
        KnowledgeArticle(title: "Blueprint Best Practices", category: "Design"),
        KnowledgeArticle(title: "Financial Planning for Farms", category: "Finance")
    ]
    
    var filteredArticles: [KnowledgeArticle] {
        if searchText.isEmpty {
            return articles
        } else {
            return articles.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText)
            
            List(filteredArticles) { article in
                VStack(alignment: .leading) {
                    Text(article.title)
                        .font(.headline)
                    Text(article.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Knowledge Vault")
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        KnowledgeVaultView()
    }
}
