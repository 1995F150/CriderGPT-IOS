import SwiftUI
import PhotosUI

struct ReceiptsView: View {
    @StateObject private var service = ReceiptsService.shared
    @State private var showingAddReceipt = false
    
    var body: some View {
        List {
            if service.receipts.isEmpty && !service.isLoading {
                Text("No receipts found. Tap + to add one.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(service.receipts) { receipt in
                    HStack {
                        AsyncImage(url: URL(string: receipt.imageURL)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(receipt.title)
                                .font(.headline)
                            Text(receipt.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("$\(receipt.amount, specifier: "%.2f")")
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Receipts")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddReceipt = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddReceipt) {
            AddReceiptView()
        }
        .refreshable {
            try? await service.fetchReceipts()
        }
        .task {
            try? await service.fetchReceipts()
        }
    }
}

struct AddReceiptView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var service = ReceiptsService.shared
    
    @State private var title = ""
    @State private var amountString = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isUploading = false
    @State private var errorMsg: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Receipt Details") {
                    TextField("Store/Item Title", text: $title)
                    TextField("Amount", text: $amountString)
                        .keyboardType(.decimalPad)
                }
                
                Section("Receipt Image") {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let data = selectedImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 250)
                                .cornerRadius(12)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 40))
                                Text("Select Receipt Photo")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                }
                
                if let error = errorMsg {
                    Section {
                        Text(error).foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: upload) {
                        if isUploading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Save Receipt")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(title.isEmpty || amountString.isEmpty || selectedImageData == nil || isUploading)
                }
            }
            .navigationTitle("Add Receipt")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
        }
    }
    
    func upload() {
        guard let data = selectedImageData, let amount = Double(amountString) else { return }
        isUploading = true
        errorMsg = nil
        
        Task {
            do {
                let fileName = "\(UUID().uuidString).jpg"
                let url = try await service.uploadReceiptImage(data: data, fileName: fileName)
                try await service.saveReceiptMetadata(title: title, amount: amount, date: Date(), imageURL: url)
                try await service.fetchReceipts()
                dismiss()
            } catch {
                await MainActor.run {
                    errorMsg = "Failed to save: \(error.localizedDescription)"
                    isUploading = false
                }
            }
        }
    }
}
