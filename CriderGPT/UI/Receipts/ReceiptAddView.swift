import SwiftUI
import PhotosUI

struct ReceiptAddView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var service = ReceiptsService.shared
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var merchant = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var isUploading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Receipt Image")) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        } else {
                            Label("Select Receipt", systemImage: "photo")
                        }
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImage = image
                            }
                        }
                    }
                }
                
                Section(header: Text("Details")) {
                    TextField("Merchant", text: $merchant)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Receipt")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReceipt()
                    }
                    .disabled(merchant.isEmpty || amount.isEmpty || selectedImage == nil || isUploading)
                }
            }
            .overlay {
                if isUploading {
                    ProgressView("Uploading...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func saveReceipt() {
        guard let image = selectedImage, let amountDouble = Double(amount) else { return }
        
        isUploading = true
        errorMessage = nil
        
        Task {
            do {
                try await service.uploadReceipt(image: image, merchant: merchant, amount: amountDouble, date: date)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isUploading = false
            }
        }
    }
}
