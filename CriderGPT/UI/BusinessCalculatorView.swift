import SwiftUI

struct BusinessCalculatorView: View {
    @State private var revenue: String = ""
    @State private var expenses: String = ""
    @State private var result: Double?
    
    var body: some View {
        Form {
            Section(header: Text("Business Metrics")) {
                TextField("Total Revenue", text: $revenue)
                    .keyboardType(.decimalPad)
                TextField("Total Expenses", text: $expenses)
                    .keyboardType(.decimalPad)
            }
            
            Section {
                Button(action: calculateProfit) {
                    Text("Calculate Profit")
                        .frame(maxWidth: .infinity)
                }
            }
            
            if let profit = result {
                Section(header: Text("Results")) {
                    HStack {
                        Text("Net Profit")
                        Spacer()
                        Text("$\(profit, specifier: "%.2f")")
                            .foregroundColor(profit >= 0 ? .green : .red)
                            .bold()
                    }
                }
            }
        }
        .navigationTitle("Business Calculator")
    }
    
    private func calculateProfit() {
        let rev = Double(revenue) ?? 0
        let exp = Double(expenses) ?? 0
        result = rev - exp
    }
}
