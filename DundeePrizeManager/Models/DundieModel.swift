import Foundation
import CloudKitMagicCRUD
import CloudKit

struct DundieModel: CKMRecord {
    var recordName: String? // UUID?
    var emoji: String
    var dundieImage: Data?
    var dundieName: String
    var descricao: String
    var createdAt: Date = Date()
}

struct DundieVote: CKMRecord {
    var recordName: String? // UUID?
    var idVotador: String
    var idVotante: String
    var idDundie: String
}

struct DundieEmployee: Codable, Equatable, Identifiable {
    let id = UUID()
    let name: String
    let fotoPerfil: String
    let isAdmin: Bool
}

struct DundieEmployeePage: Codable {
    let results: [DundieEmployee]
}

struct DundieUser: CKMRecord {
    var recordName: String? // UUID?
    var icloudID: String
    var profilePic: Data?
    var userName: String
}
