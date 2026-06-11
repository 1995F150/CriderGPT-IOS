import Foundation

enum FeatureCatalog {
    static let sections: [(title: String, routes: [AppRoute])] = [
        ("MAIN", [.chat, .visionMemory]),
        ("PRODUCTIVITY", [.livestockID, .receipts, .agentSwarm, .voiceStudio, .sharedSpending, .ffaCenter, .calendar, .calculators, .files, .gallery, .projects]),
        ("CREATIVE", [.media, .music, .aiImages, .studio3D]),
        ("ACCOUNT", [.guardian, .profile, .plan, .payment]),
        ("TOOLS", [.codeEditor, .zipToExeBuilder, .textureGenerator, .cloudGaming, .rdr2Guide, .usbHub, .sensors, .frequencyTools, .metadataEditor, .converter3D]),
        ("STORE", [.smartIDStore]),
        ("INFO", [.updates, .timeline, .memorial, .contact]),
        ("EXTERNAL", [.farmingSimulator]),
        ("ADMIN", [.adminPanel, .ideaPlanner, .devHub])
    ]

    static let all: [FeatureSpec] = [
        FeatureSpec(id: "chat", title: "Chat", subtitle: "Streaming assistant, file uploads, voice mode", section: "MAIN", route: .chat, requiresBackend: true),
        FeatureSpec(id: "visionMemory", title: "Vision Memory", subtitle: "Image memories, categories, and filters", section: "MAIN", route: .visionMemory, requiresBackend: true),
        FeatureSpec(id: "livestockID", title: "Livestock ID", subtitle: "Core NFC and manual tag entry", section: "PRODUCTIVITY", route: .livestockID, requiresBackend: true),
        FeatureSpec(id: "receipts", title: "Receipts", subtitle: "Capture and track purchase records", section: "PRODUCTIVITY", route: .receipts, requiresBackend: true),
        FeatureSpec(id: "agentSwarm", title: "Agent Swarm", subtitle: "Dispatch and monitor agent tasks", section: "PRODUCTIVITY", route: .agentSwarm, requiresBackend: true),
        FeatureSpec(id: "voiceStudio", title: "Voice Studio", subtitle: "Native voice creation workflows", section: "PRODUCTIVITY", route: .voiceStudio, requiresBackend: true),
        FeatureSpec(id: "sharedSpending", title: "Shared Spending", subtitle: "Family and team expenses", section: "PRODUCTIVITY", route: .sharedSpending, requiresBackend: true),
        FeatureSpec(id: "ffaCenter", title: "FFA Center", subtitle: "Chapters, resources, and record book", section: "PRODUCTIVITY", route: .ffaCenter, requiresBackend: true),
        FeatureSpec(id: "calendar", title: "Calendar", subtitle: "Month, week, day, and agenda views", section: "PRODUCTIVITY", route: .calendar, requiresBackend: true),
        FeatureSpec(id: "calculators", title: "Calculators", subtitle: "Multi-mode calculator suite", section: "PRODUCTIVITY", route: .calculators, requiresBackend: false),
        FeatureSpec(id: "files", title: "Files", subtitle: "Upload, download, preview, and delete", section: "PRODUCTIVITY", route: .files, requiresBackend: true),
        FeatureSpec(id: "gallery", title: "Gallery", subtitle: "Media previews and browsing", section: "PRODUCTIVITY", route: .gallery, requiresBackend: true),
        FeatureSpec(id: "projects", title: "Projects", subtitle: "Organize work and milestones", section: "PRODUCTIVITY", route: .projects, requiresBackend: true),
        FeatureSpec(id: "media", title: "Media", subtitle: "Creative media workspace", section: "CREATIVE", route: .media, requiresBackend: true),
        FeatureSpec(id: "music", title: "Music", subtitle: "Generate and manage audio ideas", section: "CREATIVE", route: .music, requiresBackend: true),
        FeatureSpec(id: "aiImages", title: "AI Images", subtitle: "Image generation with edge function support", section: "CREATIVE", route: .aiImages, requiresBackend: true),
        FeatureSpec(id: "studio3D", title: "3D Studio", subtitle: "3D assets and conversions", section: "CREATIVE", route: .studio3D, requiresBackend: true),
        FeatureSpec(id: "guardian", title: "Guardian", subtitle: "Account protection and monitoring", section: "ACCOUNT", route: .guardian, requiresBackend: true),
        FeatureSpec(id: "profile", title: "Profile", subtitle: "Settings, usage, and account controls", section: "ACCOUNT", route: .profile, requiresBackend: true),
        FeatureSpec(id: "plan", title: "Plan", subtitle: "Free, Plus, and Pro plan status", section: "ACCOUNT", route: .plan, requiresBackend: false),
        FeatureSpec(id: "payment", title: "Payment", subtitle: "StoreKit 2 subscriptions and restore", section: "ACCOUNT", route: .payment, requiresBackend: true),
        FeatureSpec(id: "codeEditor", title: "Code Editor", subtitle: "Edit native code and projects", section: "TOOLS", route: .codeEditor, requiresBackend: true),
        FeatureSpec(id: "zipToExeBuilder", title: "ZIP-to-EXE Builder", subtitle: "Packaging workflow for desktop builds", section: "TOOLS", route: .zipToExeBuilder, requiresBackend: true),
        FeatureSpec(id: "textureGenerator", title: "Texture Generator", subtitle: "Build textures and materials", section: "TOOLS", route: .textureGenerator, requiresBackend: true),
        FeatureSpec(id: "cloudGaming", title: "Cloud Gaming", subtitle: "Remote play and game catalog", section: "TOOLS", route: .cloudGaming, requiresBackend: true),
        FeatureSpec(id: "rdr2Guide", title: "RDR2 Guide", subtitle: "Reference and checklist support", section: "TOOLS", route: .rdr2Guide, requiresBackend: false),
        FeatureSpec(id: "usbHub", title: "USB Hub", subtitle: "Accessory controls and device notes", section: "TOOLS", route: .usbHub, requiresBackend: true),
        FeatureSpec(id: "sensors", title: "Sensors", subtitle: "Device and external sensor data", section: "TOOLS", route: .sensors, requiresBackend: true),
        FeatureSpec(id: "frequencyTools", title: "Frequency Tools", subtitle: "Signal utilities and generators", section: "TOOLS", route: .frequencyTools, requiresBackend: true),
        FeatureSpec(id: "metadataEditor", title: "Metadata Editor", subtitle: "Edit file and media metadata", section: "TOOLS", route: .metadataEditor, requiresBackend: true),
        FeatureSpec(id: "converter3D", title: "3D Converter", subtitle: "Convert supported 3D file types", section: "TOOLS", route: .converter3D, requiresBackend: true),
        FeatureSpec(id: "smartIDStore", title: "Smart ID Store", subtitle: "Open cridergpt.com/store", section: "STORE", route: .smartIDStore, requiresBackend: false),
        FeatureSpec(id: "updates", title: "Updates", subtitle: "Latest app and platform updates", section: "INFO", route: .updates, requiresBackend: true),
        FeatureSpec(id: "timeline", title: "Timeline", subtitle: "History, milestones, and notes", section: "INFO", route: .timeline, requiresBackend: true),
        FeatureSpec(id: "memorial", title: "Memorial", subtitle: "In loving memory screen", section: "INFO", route: .memorial, requiresBackend: false),
        FeatureSpec(id: "contact", title: "Contact", subtitle: "Email and phone contact actions", section: "INFO", route: .contact, requiresBackend: false),
        FeatureSpec(id: "farmingSimulator", title: "Farming Simulator", subtitle: "External launcher and info", section: "EXTERNAL", route: .farmingSimulator, requiresBackend: false),
        FeatureSpec(id: "adminPanel", title: "Admin Panel", subtitle: "Permission-protected admin tools", section: "ADMIN", route: .adminPanel, requiresBackend: true),
        FeatureSpec(id: "ideaPlanner", title: "Idea Planner", subtitle: "Blueprints, notes, and imports", section: "ADMIN", route: .ideaPlanner, requiresBackend: true),
        FeatureSpec(id: "devHub", title: "Dev Hub", subtitle: "Owner/admin-only workflow tools", section: "ADMIN", route: .devHub, requiresBackend: true)
    ]

    static func feature(for route: AppRoute) -> FeatureSpec? {
        all.first(where: { $0.route == route })
    }
}
