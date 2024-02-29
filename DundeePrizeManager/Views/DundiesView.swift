import SwiftUI
import CloudKitMagicCRUD

// Pegar o email do Icloud do usuário assim como o pg falou e usar o mesmo como idVotador nos votos!
// Dessa forma ja permitimos diversos usuarios utilizarem o app e votarem em funcionarios diferentes

extension Color {
    
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

struct DundiesView: View, CKMRecordObserver {
    
    @State var dundies: [DundieModel] = []
    
    @State var isPresentingAddSheet: Bool = false
    
    @State var searchText = ""
    
    @State var vaiVotar: Bool = false
    
    @State var isLoading = false
    
    var filteredDundie: [DundieModel] {
        return searchText == "" ? dundies : dundies.filter {
            $0.dundieName.lowercased().contains(searchText.lowercased()) // pq o $0?
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                VStack {
                    ZStack {
                        Color.white
                        VStack {
                            if isLoading {
                               ProgressView()
                                    .controlSize(.extraLarge)
                            }
                            else {
                                listaDundies
                            }
                        }
                    }
                    Spacer()
                    .navigationBarItems(
                        leading: VStack {
                            Spacer()
                            Text("The Awards")
                                .font(Font.custom("American Typewriter", size: 30))
                                .foregroundStyle(.black)
                                .padding()
                        },
                        trailing: HStack {
//                            EditButton()
                            Button {
                            } label: {
                                Image(systemName: "square.and.pencil")
                                    .foregroundStyle(Color.ourGreen)
                            }
                            Button {
                                isPresentingAddSheet.toggle()
                            } label: {
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(Color.ourGreen)
                            }
                        }
                        )
                }
                .accentColor(.black)
                .animation(.easeInOut, value: isLoading)

            }
            .sheet(isPresented: $isPresentingAddSheet, content: {
                AddDundieView(dundies: $dundies, isShowing: $isPresentingAddSheet)
            })
        }
        .searchable(text: $searchText)
        .animation(.easeIn(duration: 0.3), value: filteredDundie.count)
        .task {
            recieveDundies()
        }
    }
    
    var listaDundies: some View {
        VStack {
            List {
                Section("") {
                    ForEach(filteredDundie, id: \.recordName) { dundie in
                        NavigationLink(destination: DundieDetailView(idDundie: dundie.recordName ?? dundie.dundieName, dundie: dundie)) {
                            HStack {
                                if dundie.dundieImage != nil {
                                    Image(uiImage: UIImage(data: dundie.dundieImage!)!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 45, height: 45) // Ajuste conforme necessário
                                        .clipShape(Circle())
                                } else {
                                    Text(dundie.emoji)
                                }
                                Text(dundie.dundieName)
                                    .font(.system(size: 20))
                                    .opacity(0.6)
                                    .foregroundStyle(.black)
                            }
                            .padding(7.5)
                        }
                        .listRowBackground(Color.rowBackground)
                    }
                }
            }
            .background(.white)
            .scrollContentBackground(.hidden)
        }
    }
    
    // faz nada ainda
    func delete(indexSet: IndexSet) {
            dundies.remove(atOffsets: indexSet)
        }
    
    func recieveDundies() {
        isLoading = true
        DundieModel.ckLoadAll(then: { result in
            switch result {
                case .success(let loadedDundies):
                    self.dundies = (loadedDundies as? [DundieModel]) ?? self.dundies
                    self.dundies.sort {$0.createdAt < $1.createdAt}
                case .failure(let error):
                    debugPrint("Cannot load new messages")
                    debugPrint(error)
            }
            isLoading = false
        })
    }
    
    func onReceive(notification: CloudKitMagicCRUD.CKMNotification) {
//        if #available(iOS 15.0, *) {
//            print("New Message at \(notification.date.formatted(date: .omitted, time: .complete))")
//            print(notification.body, notification.title, notification.userID ?? "")
//        } else {
//            print("New Message at \(notification.date)")
//        }
        
        recieveDundies()
    }
}

#Preview {
    DundiesView()
}
