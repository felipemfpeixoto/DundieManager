//
//  ContentView.swift
//  DundeePrizeManager
//
//  Created by infra on 20/02/24.
//

import SwiftUI

let dao = DAO()

struct ContentView: View {
    
    var body: some View {
        TabView {
            Group {
                DundiesView()
                    .tabItem {
                        VStack {
                            Image(systemName: "list.bullet.clipboard")
                                .environment(\.symbolVariants, .none)
                            Text("Dundies")
                        }
                    }
                
                DundieDetailView(idDundie: "", dundie: DundieModel(emoji: "", dundieImage: nil, dundieName: "", descricao: ""))
                    .tabItem {
                        VStack {
                            Image(systemName: "text.append")
                            Text("Dundies")
                        }
                    }
                
                DundiesView()
                    .tabItem {
                        VStack {
                            Image(systemName: "gear")
                            Text("Dundies")
                        }
                    }
            }
            .toolbarBackground(Color.ourGreen, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
        .accentColor(.black)
    }
}


