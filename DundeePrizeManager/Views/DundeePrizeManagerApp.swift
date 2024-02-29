import SwiftUI
import CloudKitMagicCRUD

@main
struct DundeePrizeManagerApp: App {
    
    init() {
        CKMDefault.containerIdentifier = "iCloud.newContainerforCloudServices"
        Task {
            try await dao.getUserID()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        
    }
}
