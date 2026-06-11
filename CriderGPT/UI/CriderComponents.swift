import SwiftUI

struct CriderCard<Content: View>: View {
    let title: String?
    let subtitle: String?
    @ViewBuilder let content: Content

    init(title: String? = nil, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CriderTheme.cream)
            }
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(CriderTheme.goldSoft.opacity(0.92))
            }
            content
        }
        .padding(16)
        .background(CriderTheme.card.opacity(0.95))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(CriderTheme.borderBlue.opacity(0.7), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct CriderPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(CriderTheme.navyDeep)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(CriderTheme.gold.opacity(configuration.isPressed ? 0.75 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct CriderSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(CriderTheme.cream)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(CriderTheme.card.opacity(configuration.isPressed ? 0.75 : 1))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(CriderTheme.borderBlue.opacity(0.9), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct SectionBadge: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(CriderTheme.gold)
            .background(CriderTheme.gold.opacity(0.12))
            .clipShape(Capsule())
    }
}
