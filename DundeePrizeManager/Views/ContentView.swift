//
//  ContentView.swift
//  DundeePrizeManager
//
//  Created by infra on 20/02/24.
//

import SwiftUI

let dao = DAO()
var icloudUser: DundieUser?

struct ContentView: View {
    
    @State var users: [DundieUser] = []
    
    @State var showFullScreen = false
    
    @State var isLoadingUser = false
    
    var body: some View {
        ZStack {
            DundiesView(isLoadingUser: $isLoadingUser)
        }
        .fullScreenCover(isPresented: $showFullScreen, content: {
            CreateUserView(showFullScreen: $showFullScreen)
        })
        .task {
            getUsers()
        }
    }
    
    func getUsers() {
        isLoadingUser = true
        DundieUser.ckLoadAll(then: { result in
            switch result {
            case .success(let loadedUsers):
                print(loadedUsers)
                self.users = (loadedUsers as? [DundieUser]) ?? self.users
                self.users = self.users.filter { $0.icloudID == dao.userID?.recordName }
                if self.users.count > 0 {
                    icloudUser = self.users[0]
                    print(icloudUser)
                } else {
                    // Subir o alerta de criacao de usuario
                    showFullScreen = true
                }
            case .failure(let error):
                debugPrint("Cannot load users")
                debugPrint(error)
            }
            isLoadingUser = false
        })
    }
}


