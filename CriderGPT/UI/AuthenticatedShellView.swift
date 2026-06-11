import SwiftUI

struct AuthenticatedShellView: View {
    @EnvironmentObject private var model: AppModel
    @State private var profileMenuOpen = false

    var body: some View {
        NavigationStack(path: $model.path) {
            DashboardView(profileMenuOpen: $profileMenuOpen)
                .navigationDestination(for: AppRoute.self) { route in
                    RouteDestinationView(route: route)
                }
                .toolbarBackground(CriderTheme.navyDeep, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
        .sheet(isPresented: $profileMenuOpen) {
            NativeProfileMenuView(isPresented: $profileMenuOpen)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject private var model: AppModel
    @Binding var profileMenuOpen: Bool
    @State private var searchText = ""

    private var filteredFeatures: [FeatureSpec] {
        guard searchText.isEmpty == false else { return FeatureCatalog.all }
        return FeatureCatalog.all.filter { feature in
            feature.title.localizedCaseInsensitiveContains(searchText) || feature.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                topActions
                planSummary
                ForEach(FeatureCatalog.sections, id: \.title) { section in
                    let sectionFeatures = filteredFeatures.filter { $0.section == section.title }
                    if sectionFeatures.isEmpty == false {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionBadge(title: section.title)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(sectionFeatures) { feature in
                                    Button {
                                        model.go(feature.route)
                                    } label: {
                                        featureCard(feature)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search modules")
        .navigationTitle("CriderGPT")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            BottomNavBar()
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dashboard")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(CriderTheme.cream)
                Text(model.profile?.fullName ?? model.profile?.email ?? "Signed in")
                    .foregroundStyle(CriderTheme.goldSoft)
            }
            Spacer()
            Button {
                profileMenuOpen = true
            } label: {
                Circle()
                    .fill(CriderTheme.gold.opacity(0.18))
                    .frame(width: 48, height: 48)
                    .overlay(Text(initials).foregroundStyle(CriderTheme.gold).font(.headline.weight(.bold)))
            }
        }
    }

    private var initials: String {
        let name = model.profile?.fullName ?? model.profile?.email ?? "CG"
        let parts = name.split(separator: " ")
        if let first = parts.first {
            let second = parts.dropFirst().first?.first.map(String.init) ?? ""
            return String(first.prefix(1)) + second
        }
        return String(name.prefix(2)).uppercased()
    }

    private var topActions: some View {
        HStack(spacing: 10) {
            Button("New Chat") { model.go(.chat) }
                .buttonStyle(CriderPrimaryButtonStyle())
            Button("Agent Swarm") { model.go(.agentSwarm) }
                .buttonStyle(CriderSecondaryButtonStyle())
        }
    }

    private var planSummary: some View {
        CriderCard(title: "Subscription", subtitle: "Only one plan can be current at a time") {
            HStack(spacing: 10) {
                planChip(.free)
                planChip(.plus)
                planChip(.pro)
            }
        }
    }

    private func planChip(_ plan: SubscriptionPlan) -> some View {
        let state = model.planDisplayState(for: plan)
        return VStack(alignment: .leading, spacing: 4) {
            Text(plan.rawValue)
                .font(.headline.weight(.semibold))
            Text(state.label)
                .font(.caption)
        }
        .foregroundStyle(state == .current ? CriderTheme.navyDeep : CriderTheme.cream)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(state == .current ? CriderTheme.gold : CriderTheme.card)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(CriderTheme.borderBlue.opacity(0.8), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func featureCard(_ feature: FeatureSpec) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(feature.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CriderTheme.cream)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(CriderTheme.goldSoft)
                    .font(.caption.weight(.bold))
            }
            Text(feature.subtitle)
                .font(.caption)
                .foregroundStyle(CriderTheme.goldSoft.opacity(0.9))
                .lineLimit(3)
            if feature.requiresBackend {
                Text("Backend hookup required")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(CriderTheme.gold)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .background(CriderTheme.card.opacity(0.95))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(CriderTheme.borderBlue.opacity(0.65), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct BottomNavBar: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        HStack(spacing: 10) {
            navButton(title: "Chat", route: .chat, systemImage: "message")
            navButton(title: "Plan", route: .plan, systemImage: "creditcard")
            navButton(title: "Profile", route: .profile, systemImage: "person.circle")
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial.opacity(0.85))
        .background(CriderTheme.navyDeep.opacity(0.96))
        .overlay(Rectangle().frame(height: 1).foregroundStyle(CriderTheme.borderBlue.opacity(0.5)), alignment: .top)
    }

    private func navButton(title: String, route: AppRoute, systemImage: String) -> some View {
        Button {
            model.go(route)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.headline)
                Text(title)
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(model.selectedRoute == route ? CriderTheme.navyDeep : CriderTheme.cream)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(model.selectedRoute == route ? CriderTheme.gold : CriderTheme.card)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(CriderTheme.borderBlue.opacity(0.7), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
