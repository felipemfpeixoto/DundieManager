import Foundation
import CloudKitMagicCRUD
import CloudKit

struct DundieModel: CKMRecord {
    var recordName: String?
    var emoji: String
    var dundieImage: Data?
    var dundieName: String
    var descricao: String
    var createdAt: Date = Date()
    var dundieGroupID: String
}

struct DundieEmployee: Codable, Equatable, Identifiable {
    var id = UUID()
    let name: String
    let fotoPerfil: String
    let isAdmin: Bool // talvez colocar o isAdmin como um array de recordNames de users no modelo do grupo
}

// Grupo para um academy criar seus dundies
struct DundieGroup: CKMRecord {
    var recordName: String?
    var groupImage: Data
    var groupName: String
    var groupDescription: String
    var admind: String
    var createdAt: Date = Date()
}

struct DundieVote: CKMRecord {
    var recordName: String? // UUID?
    var idVotador: String
    var idVotante: String
    var idDundie: String
}

struct DundieEmployeePage: Codable {
    let results: [DundieEmployee]
}

struct DundieUser: CKMRecord {
    var recordName: String? // UUID?
    var icloudID: String
    var profilePic: Data?
    var userName: String
    var dundieGroups: [String]
}
