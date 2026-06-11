import SwiftUI

@main
struct CriderGPTApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .task {
                    await model.boot()
                }
        }
    }
}
