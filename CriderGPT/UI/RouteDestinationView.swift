import SwiftUI
import SafariServices

struct RouteDestinationView: View {
    @EnvironmentObject private var model: AppModel
    let route: AppRoute

    var body: some View {
        Group {
            switch route {
            case .chat:
                ChatScreenView()
            case .visionMemory:
                VisionMemoryView()
            case .livestockID:
                LivestockIDView()
            case .receipts:
                GenericBackendView(title: "Receipts", subtitle: "Capture, organize, and sync receipts.")
            case .agentSwarm:
                GenericBackendView(title: "Agent Swarm", subtitle: "Dispatch workflows to the server agent swarm.")
            case .voiceStudio:
                GenericBackendView(title: "Voice Studio", subtitle: "Generate and review voice assets.")
            case .sharedSpending:
                GenericBackendView(title: "Shared Spending", subtitle: "Split and track shared expenses.")
            case .ffaCenter:
                FFACenterView()
            case .calendar:
                CalendarHubView()
            case .calculators:
                CalculatorsView()
            case .files:
                FilesHubView()
            case .gallery:
                GenericBackendView(title: "Gallery", subtitle: "Browse stored media and previews.")
            case .projects:
                GenericBackendView(title: "Projects", subtitle: "Track projects, milestones, and workstreams.")
            case .media:
                GenericBackendView(title: "Media", subtitle: "Work with content, uploads, and playback.")
            case .music:
                GenericBackendView(title: "Music", subtitle: "Generate and organize music ideas.")
            case .aiImages:
                GenericBackendView(title: "AI Images", subtitle: "Create images through the generate-image edge function.")
            case .studio3D:
                GenericBackendView(title: "3D Studio", subtitle: "Model, view, and convert 3D assets.")
            case .guardian:
                GenericBackendView(title: "Guardian", subtitle: "Account safety and device monitoring.")
            case .profile:
                ProfileScreenView()
            case .plan:
                PlanScreenView()
            case .payment:
                PaymentScreenView()
            case .codeEditor:
                GenericBackendView(title: "Code Editor", subtitle: "Open native editing workflows.")
            case .zipToExeBuilder:
                GenericBackendView(title: "ZIP-to-EXE Builder", subtitle: "Package build artifacts for desktop workflows.")
            case .textureGenerator:
                GenericBackendView(title: "Texture Generator", subtitle: "Create and manage texture sets.")
            case .cloudGaming:
                GenericBackendView(title: "Cloud Gaming", subtitle: "Remote game access and session management.")
            case .rdr2Guide:
                GenericBackendView(title: "RDR2 Guide", subtitle: "Guide content and quick references.")
            case .usbHub:
                GenericBackendView(title: "USB Hub", subtitle: "Accessory and device hub management.")
            case .sensors:
                GenericBackendView(title: "Sensors", subtitle: "Device sensor readouts and logs.")
            case .frequencyTools:
                GenericBackendView(title: "Frequency Tools", subtitle: "Signal tools and frequency utilities.")
            case .metadataEditor:
                GenericBackendView(title: "Metadata Editor", subtitle: "Inspect and edit file metadata.")
            case .converter3D:
                GenericBackendView(title: "3D Converter", subtitle: "Convert 3D assets and package outputs.")
            case .smartIDStore:
                SmartIDStoreView()
            case .updates:
                GenericBackendView(title: "Updates", subtitle: "Latest application and backend updates.")
            case .timeline:
                GenericBackendView(title: "Timeline", subtitle: "App timeline and milestones.")
            case .memorial:
                MemorialView()
            case .contact:
                ContactView()
            case .farmingSimulator:
                ExternalLinkView()
            case .adminPanel:
                AdminPanelView()
            case .ideaPlanner:
                IdeaPlannerView()
            case .devHub:
                DevHubView()
            }
        }
        .navigationTitle(routeTitle)
        .navigationBarTitleDisplayMode(.inline)
        .background(CriderTheme.navyDeep.ignoresSafeArea())
        .task {
            model.selectedRoute = route
        }
    }

    private var routeTitle: String {
        FeatureCatalog.feature(for: route)?.title ?? "CriderGPT"
    }
}

struct GenericBackendView: View {
    let title: String
    let subtitle: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CriderCard(title: title, subtitle: subtitle) {
                    Text("Backend hookup required")
                        .foregroundStyle(CriderTheme.goldSoft)
                }
                CriderCard(title: "Notes") {
                    Text("This native screen is wired into navigation and ready for Supabase-backed data.")
                        .foregroundStyle(CriderTheme.cream)
                }
            }
            .padding(16)
        }
    }
}

struct SmartIDStoreView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CriderCard(title: "Smart ID Store", subtitle: "Open the store in Safari or the external browser") {
                    Button {
                        if let url = URL(string: "https://cridergpt.com/store") {
                            openURL(url)
                        }
                    } label: {
                        Label("Open Store", systemImage: "arrow.up.right.square")
                    }
                    .buttonStyle(CriderPrimaryButtonStyle())
                }
            }
            .padding(16)
        }
    }
}

struct ExternalLinkView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CriderCard(title: "Farming Simulator", subtitle: "Launch external content") {
                    Button {
                        if let url = URL(string: "https://cridergpt.com") {
                            openURL(url)
                        }
                    } label: {
                        Label("Open External Link", systemImage: "link")
                    }
                    .buttonStyle(CriderPrimaryButtonStyle())
                }
            }
            .padding(16)
        }
    }
}

struct MemorialView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CriderCard(title: "In Loving Memory", subtitle: "Jerry Blankenship") {
                    Text("Your memory will live on in our stories and love. Rest easy, Uncle Jerry.")
                        .foregroundStyle(CriderTheme.cream)
                }
            }
            .padding(16)
        }
    }
}

struct ContactView: View {
    private let email = "jessiecrider3@gmail.com"
    private let phone = "+1 (276) 613-8641"
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CriderCard(title: "Contact", subtitle: "Use the native iOS actions below") {
                    Button("Copy Email") { UIPasteboard.general.string = email }
                        .buttonStyle(CriderSecondaryButtonStyle())
                    Button("Copy Phone") { UIPasteboard.general.string = phone }
                        .buttonStyle(CriderSecondaryButtonStyle())
                    Button("Send Email") {
                        if let url = URL(string: "mailto:\(email)") { openURL(url) }
                    }
                    .buttonStyle(CriderPrimaryButtonStyle())
                    Button("Call Now") {
                        if let url = URL(string: "tel://2766138641") { openURL(url) }
                    }
                    .buttonStyle(CriderPrimaryButtonStyle())
                }
            }
            .padding(16)
        }
    }
}

struct FFACenterView: View {
    @State private var tab = 0
    private let tabs = ["Dashboard", "Crop Planner", "Livestock", "Calculators", "Precision Ag", "Record Book", "Resources"]

    var body: some View {
        VStack(spacing: 12) {
            Picker("FFA Center", selection: $tab) {
                ForEach(tabs.indices, id: \.self) { index in
                    Text(tabs[index]).tag(index)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            TabView(selection: $tab) {
                ForEach(tabs.indices, id: \.self) { index in
                    GenericBackendView(title: tabs[index], subtitle: "FFA Center content for \(tabs[index]).")
                        .tag(index)
                        .padding(.top, 8)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(CriderTheme.navyDeep.ignoresSafeArea())
    }
}

struct CalendarHubView: View {
    @State private var viewMode = 0
    private let modes = ["Month View", "Week View", "Day View", "Agenda View"]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CriderCard(title: "Calendar", subtitle: "Chapter events, personal events, and notifications") {
                    Picker("Calendar View", selection: $viewMode) {
                        ForEach(modes.indices, id: \.self) { index in
                            Text(modes[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text("Add Event")
                        .font(.headline)
                        .foregroundStyle(CriderTheme.cream)
                    Text("Backend hookup required")
                        .foregroundStyle(CriderTheme.goldSoft)
                }
            }
            .padding(16)
        }
    }
}

struct CalculatorsView: View {
    private let calculators = ["Advanced", "Welding", "Mechanics", "Farming", "Electrical", "Vehicle", "Probability", "Loan", "Science", "Health", "Random Math", "Conversions"]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(calculators, id: \.self) { calculator in
                    CriderCard(title: calculator, subtitle: "Native calculator module") {
                        Text("Available offline with local calculations or backend expansion.")
                            .foregroundStyle(CriderTheme.cream)
                    }
                }
            }
            .padding(16)
        }
    }
}

struct FilesHubView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CriderCard(title: "Files", subtitle: "Supabase Storage upload, download, delete, and preview") {
                    HStack {
                        Label("Upload", systemImage: "square.and.arrow.up")
                        Spacer()
                        Label("Download", systemImage: "arrow.down.circle")
                    }
                    .foregroundStyle(CriderTheme.cream)
                    Text("Backend hookup required")
                        .foregroundStyle(CriderTheme.goldSoft)
                }
            }
            .padding(16)
        }
    }
}

struct VisionMemoryView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CriderCard(title: "Vision Memory", subtitle: "Memory count, categories, and date filters") {
                    Text("No vision memories found.")
                        .foregroundStyle(CriderTheme.cream)
                    Text("Upload support is ready for the live backend.")
                        .foregroundStyle(CriderTheme.goldSoft)
                }
            }
            .padding(16)
        }
    }
}

struct LivestockIDView: View {
    @State private var selectedTab = 0
    @State private var tag = "CriderGPT-000001"

    var body: some View {
        VStack(spacing: 12) {
            Picker("Livestock", selection: $selectedTab) {
                Text("Herd").tag(0)
                Text("Scan").tag(1)
                Text("Stats").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            TabView(selection: $selectedTab) {
                CriderCard(title: "Herd", subtitle: "Tracked livestock entries") {
                    Text("Backend hookup required")
                        .foregroundStyle(CriderTheme.cream)
                }
                .padding(16)
                .tag(0)

                CriderCard(title: "Scan", subtitle: "Core NFC and manual tag entry") {
                    TextField("CriderGPT-XXXXXX", text: $tag)
                        .padding(12)
                        .background(CriderTheme.navy.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundStyle(CriderTheme.cream)
                    Text("Tag format: CriderGPT-XXXXXX")
                        .foregroundStyle(CriderTheme.goldSoft)
                }
                .padding(16)
                .tag(1)

                CriderCard(title: "Stats", subtitle: "Scan logs and livestock metrics") {
                    Text("Backend hookup required")
                        .foregroundStyle(CriderTheme.cream)
                }
                .padding(16)
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(CriderTheme.navyDeep.ignoresSafeArea())
    }
}

struct PlanScreenView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                    let state = model.planDisplayState(for: plan)
                    CriderCard(title: plan.rawValue, subtitle: state.label) {
                        Text(planDescription(for: plan, state: state))
                            .foregroundStyle(CriderTheme.cream)
                        if state == .current {
                            Text("Current Plan")
                                .foregroundStyle(CriderTheme.gold)
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    private func planDescription(for plan: SubscriptionPlan, state: PlanDisplayState) -> String {
        switch (plan, state) {
        case (.plus, .includedInPro):
            return "Included in Pro, downgrade disabled."
        case (.pro, .current):
            return "Pro is the active plan."
        case (.plus, .current):
            return "Plus is the active plan."
        case (.free, .current):
            return "Free is active until an upgrade is verified."
        case (_, .upgrade):
            return "Upgrade available after backend verification."
        default:
            return "Subscription state is verified through the backend, not local UI state."
        }
    }
}

struct PaymentScreenView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CriderCard(title: "Payment", subtitle: "StoreKit 2 for Plus and Pro") {
                    Text("Purchase, restore, and manage subscriptions.")
                        .foregroundStyle(CriderTheme.cream)
                    Button("Restore Purchases") {
                        Task { await model.refreshAccountState() }
                    }
                    .buttonStyle(CriderSecondaryButtonStyle())
                    Button("Manage Subscription") {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(CriderPrimaryButtonStyle())
                }
            }
            .padding(16)
        }
    }
}

struct ProfileScreenView: View {
    @EnvironmentObject private var model: AppModel
    @State private var darkMode = true

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CriderCard(title: "Account", subtitle: "Build Profile & Settings") {
                    profileMenuButtons
                }
                CriderCard(title: "Profile Page", subtitle: "Free Will, plan badges, SMS settings, phone number, and usage") {
                    Text("Free Will section")
                        .foregroundStyle(CriderTheme.gold)
                    Text("Plan badges: \(model.subscriptionState.currentPlan.rawValue)")
                        .foregroundStyle(CriderTheme.cream)
                    Text("Phone number: \(model.profile?.phoneNumber ?? \"Not set\")")
                        .foregroundStyle(CriderTheme.cream)
                    Text("Usage information")
                        .foregroundStyle(CriderTheme.goldSoft)
                }
            }
            .padding(16)
        }
    }

    private var profileMenuButtons: some View {
        VStack(spacing: 10) {
            Button("Account") { model.go(.profile) }
                .buttonStyle(CriderSecondaryButtonStyle())
            Button("Settings") { model.go(.profile) }
                .buttonStyle(CriderSecondaryButtonStyle())
            Button("My Files") { model.go(.files) }
                .buttonStyle(CriderSecondaryButtonStyle())
            Button("AI Settings") { model.go(.profile) }
                .buttonStyle(CriderSecondaryButtonStyle())
            Button("Usage Stats") { model.go(.profile) }
                .buttonStyle(CriderSecondaryButtonStyle())
            Button("Tokens & Credits") { model.go(.plan) }
                .buttonStyle(CriderSecondaryButtonStyle())
            Button("Feedback & Help") { model.go(.contact) }
                .buttonStyle(CriderSecondaryButtonStyle())
            Toggle("Dark Mode", isOn: $darkMode)
                .foregroundStyle(CriderTheme.cream)
            Button("Logout") {
                Task { await model.logout() }
            }
            .buttonStyle(CriderPrimaryButtonStyle())
        }
    }
}

struct NativeProfileMenuView: View {
    @EnvironmentObject private var model: AppModel
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    CriderCard(title: model.profile?.fullName ?? "Profile", subtitle: model.profile?.email ?? "Signed in") {
                        Button("Smart ID Store") {
                            model.go(.smartIDStore)
                            isPresented = false
                        }
                        .buttonStyle(CriderSecondaryButtonStyle())
                        Button("Profile") {
                            model.go(.profile)
                            isPresented = false
                        }
                        .buttonStyle(CriderSecondaryButtonStyle())
                    }
                }
                .padding(16)
            }
            .navigationTitle("Profile Menu")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { isPresented = false }
                }
            }
        }
    }
}

struct AdminPanelView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        permissionProtected(title: "Admin Panel", items: ["Server AI Console", "Self Repair", "Knowledge Vault", "AGI Dispatcher", "Android Builder", "iOS Builder", "Swift Generator", "Business Calculator", "Blueprint Generator"])
    }

    private func permissionProtected(title: String, items: [String]) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                CriderCard(title: title, subtitle: "Owner/admin only") {
                    if model.profile?.role?.lowercased().contains("admin") == true || model.profile?.role?.lowercased().contains("owner") == true {
                        ForEach(items, id: \.self) { item in
                            Text(item)
                                .foregroundStyle(CriderTheme.cream)
                        }
                    } else {
                        Text("Feature coming soon")
                            .foregroundStyle(CriderTheme.goldSoft)
                    }
                }
            }
            .padding(16)
        }
    }
}

struct IdeaPlannerView: View {
    @State private var idea = ""
    @State private var notes = ""
    @State private var selectedCategory = "General"
    private let categories = ["General", "Product", "Feature", "Content", "Automation"]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CriderCard(title: "Idea Planner", subtitle: "New Idea, Idea List, categories, and blueprint generation") {
                    TextField("New Idea", text: $idea)
                        .padding(12)
                        .background(CriderTheme.navy.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundStyle(CriderTheme.cream)
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(CriderTheme.navy.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Button("Generate Blueprint") { }
                        .buttonStyle(CriderPrimaryButtonStyle())
                    Button("Import Product") { }
                        .buttonStyle(CriderSecondaryButtonStyle())
                }
            }
            .padding(16)
        }
    }
}

struct DevHubView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CriderCard(title: "Dev Hub", subtitle: "Owner/admin only") {
                    Text("Server AI Console")
                    Text("Self Repair")
                    Text("Knowledge Vault")
                    Text("AGI Dispatcher")
                    Text("Android Builder")
                    Text("iOS Builder")
                    Text("Swift Generator")
                    Text("Business Calculator")
                    Text("Blueprint Generator")
                    Text("Feature coming soon")
                }
            }
            .padding(16)
        }
    }
}
