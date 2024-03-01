import Foundation
import SwiftUI
import CloudKit

class DAO {
    let container = CKContainer(identifier: "iCloud.newContainerforCloudServices")
    var userID: CKRecord.ID? // Property to store the user record ID

    init() {
        
    }
    
    func getUserID() async throws {
        self.userID = try await self.container.userRecordID()
    }
}

let employees = EmployeeManager().getEmployee()
