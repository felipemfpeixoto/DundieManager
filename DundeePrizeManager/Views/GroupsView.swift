//
//  GroupsView.swift
//  The Dundie Manager
//
//  Created by infra on 07/03/24.
//

import SwiftUI

struct GroupsView: View {
    
    @State var groups: [DundieGroup] = []
    
    @State var isLoadingGroups: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                VStack {
                    if isLoadingGroups {
                       ProgressView()
                            .controlSize(.extraLarge)
                    } else {
                        ForEach(groups, id: \.recordName) { group in
                            NavigationLink(destination: DundiesView(isLoadingDundies: false, isLoadingUser: true)) {
                                Text("\(group.groupName)")
                            }
                        }
                    }
                }
            }
        }
        .task {
            getGroups()
        }
    }
    
    func getGroups() {
        isLoadingGroups = true
        DundieGroup.ckLoadAll(then: { result in
            switch result {
                case .success(let loadedGroups):
                    self.groups = (loadedGroups as? [DundieGroup]) ?? self.groups
                    self.groups.sort {$0.createdAt < $1.createdAt}
                case .failure(let error):
                    debugPrint("Cannot load new messages")
                    debugPrint(error)
            }
            isLoadingGroups = false
        })
    }
}

#Preview {
    GroupsView()
}
