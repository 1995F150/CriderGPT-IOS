import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject var storeKitService = StoreKitService()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("CriderGPT Plus & Pro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Unlock advanced AI features, higher limits, and custom personas.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(storeKitService.products) { product in
                            ProductCard(product: product) {
                                Task {
                                    do {
                                        try await storeKitService.purchase(product)
                                        dismiss()
                                    } catch {
                                        print("Purchase failed: \(error)")
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                Button("Restore Purchases") {
                    Task {
                        await storeKitService.updateCustomerProductStatus()
                    }
                }
                .font(.footnote)
                .foregroundColor(.blue)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") { dismiss() })
            .task {
                await storeKitService.fetchProducts()
            }
        }
    }
}

struct ProductCard: View {
    let product: Product
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            Button(action: action) {
                Text("Subscribe Now")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    PaywallView()
}
