import SwiftUI

struct BusinessCalculatorView: View {
    @State private var revenue: String = ""
    @State private var expenses: String = ""
    @State private var taxRate: Double = 25.0
    
    private var revenueValue: Double {
        Double(revenue) ?? 0.0
    }
    
    private var expensesValue: Double {
        Double(expenses) ?? 0.0
    }
    
    private var grossProfit: Double {
        revenueValue - expensesValue
    }
    
    private var taxAmount: Double {
        max(0, grossProfit * (taxRate / 100.0))
    }
    
    private var netProfit: Double {
        grossProfit - taxAmount
    }
    
    private var profitMargin: Double {
        revenueValue > 0 ? (netProfit / revenueValue) * 100.0 : 0.0
    }
    
    var body: some View {
        Form {
            Section(header: Text("Business Metrics")) {
                HStack {
                    Text("Total Revenue")
                    Spacer()
                    TextField("$0.00", text: $revenue)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Total Expenses")
                    Spacer()
                    TextField("$0.00", text: $expenses)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section(header: Text("Tax Settings")) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Tax Rate")
                        Spacer()
                        Text("\(Int(taxRate))%")
                    }
                    Slider(value: $taxRate, in: 0...50, step: 1)
                }
            }
            
            Section(header: Text("Analysis")) {
                HStack {
                    Text("Gross Profit")
                    Spacer()
                    Text(grossProfit, format: .currency(code: "USD"))
                        .foregroundColor(grossProfit >= 0 ? .primary : .red)
                }
                
                HStack {
                    Text("Estimated Tax")
                    Spacer()
                    Text(taxAmount, format: .currency(code: "USD"))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Net Profit")
                    Spacer()
                    Text(netProfit, format: .currency(code: "USD"))
                        .fontWeight(.bold)
                        .foregroundColor(netProfit >= 0 ? .green : .red)
                }
                
                HStack {
                    Text("Profit Margin")
                    Spacer()
                    Text("\(profitMargin, specifier: "%.1f")%")
                        .fontWeight(.bold)
                        .foregroundColor(profitMargin >= 0 ? .green : .red)
                }
            }
        }
        .navigationTitle("Business Calculator")
    }
}

#Preview {
    NavigationView {
        BusinessCalculatorView()
    }
}
