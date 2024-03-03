import SwiftUI
import CloudKitMagicCRUD

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
    
    @State var isShowingProfile: Bool = false
    
    @State var isLoadingDundies = false
    
    @Binding var isLoadingUser: Bool
    
    var filteredDundie: [DundieModel] {
        return searchText == "" ? dundies : dundies.filter {
            $0.dundieName.lowercased().contains(searchText.lowercased())
        }
    }
    
    let paddingProfile = (UIScreen.main.bounds.height / 3) * 1.25
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                VStack {
                    loadingDundies
                    Spacer()
                    Button {
                        isPresentingAddSheet.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.ourGreen)
                            .font(.largeTitle.weight(.medium))
                    }
                    Spacer()
                }
                ZStack {
                    if isShowingProfile {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            .foregroundStyle(.black)
                            .opacity(0.3)
                            .ignoresSafeArea()
                        ProfileSheet(isShowingProfile: $isShowingProfile)
                            .padding(.top, 475)
                            .transition(.move(edge: .bottom))
                            .animation(.spring(duration: 0.5))
                    }
                }
                .zIndex(2.0)
            }
            .navigationTitle("The Awards")
            .navigationBarItems(
                trailing: navBarButtons
            )
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
                        NavigationLink(destination: DundieDetailView(idDundie: dundie.recordName ?? dundie.dundieName, isShowingProfile: $isShowingProfile, dundie: dundie)) {
                            HStack {
                                if dundie.dundieImage != nil {
                                    Image(uiImage: UIImage(data: dundie.dundieImage!)!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 45, height: 45)
                                        .clipShape(Circle())
                                } else {
                                    Text(dundie.emoji)
                                }
                                Text(dundie.dundieName)
                                    .font(.title3)
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
    
    var userButton: some View {
        VStack {
            if icloudUser != nil {
                Image(uiImage: UIImage(data: (icloudUser?.profilePic!)!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
            }
        }
    }
    
    var navBarButtons: some View {
        VStack {
            HStack {
                Button {
                    recieveDundies()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(Color.ourGreen)
                        .font(.title3.weight(.semibold))
                }
                Button {
                    isShowingProfile = true
                } label: {
                    userButton
                }
            }
            .accentColor(.black)
            .animation(.easeInOut, value: isLoadingUser)
        }
    }
    
    var loadingDundies: some View {
        ZStack {
            Color.white
            VStack {
                if isLoadingDundies && isLoadingUser {
                   ProgressView()
                        .controlSize(.extraLarge)
                }
                else {
                    listaDundies
                    Spacer()
                }
            }
        }
    }
    
    // faz nada ainda
    func delete(indexSet: IndexSet) {
        dundies.remove(atOffsets: indexSet)
    }
    
    func recieveDundies() {
        isLoadingDundies = true
        isLoadingUser = true
        DundieModel.ckLoadAll(then: { result in
            switch result {
                case .success(let loadedDundies):
                    self.dundies = (loadedDundies as? [DundieModel]) ?? self.dundies
                    self.dundies.sort {$0.createdAt < $1.createdAt}
                case .failure(let error):
                    debugPrint("Cannot load new messages")
                    debugPrint(error)
            }
            isLoadingUser = false
            isLoadingDundies = false
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

struct ProfileSheet: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var isShowingProfile: Bool
    
    var body: some View {
        ZStack {
            Color.ourGreen
                .ignoresSafeArea()
                .clipShape(RoundedRectangle(cornerRadius: 40))
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        isShowingProfile.toggle()
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                            .font(.title3.weight(.medium))
                            .padding(20)
                    })
                    Spacer()
                }
                Spacer()
            }
            Spacer()
            VStack {
                if icloudUser != nil {
                    Image(uiImage: UIImage(data: (icloudUser?.profilePic!)!)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                }
                HStack {
                    Text(icloudUser?.userName ?? "Mengo")
                        .font(.headline)
                        .foregroundStyle(Color.ourGreen)
                        .padding()
                }
                .frame(width: 253, height: 44)
                .background(Color.rowBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(40)
            }
            Spacer()
        }
        .ignoresSafeArea()
    }
}
