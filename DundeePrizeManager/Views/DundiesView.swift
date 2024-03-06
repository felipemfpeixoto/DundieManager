import SwiftUI
import CloudKitMagicCRUD

struct DundiesView: View, CKMRecordObserver {
    
    @State var dundies: [DundieModel] = []
    
    @State var isPresentingAddSheet: Bool = false
    
    @State var searchText = ""
    
    @State var vaiVotar: Bool = false
    
    @State var isShowingProfile: Bool = false
    
    @State var isLoadingDundies = false
    
    let isLoadingUser: Bool
    
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
                    if isShowingProfile {
                        Rectangle()
                            .ignoresSafeArea()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            .opacity(0)
                    }
                    HStack {
                        Spacer()
                        EditButton()
                            .foregroundStyle(Color.ourGreen)
                            .padding(.trailing, 20)
                    }
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
                .animation(.easeIn(duration: 0.3), value: isShowingProfile)
                .allowsHitTesting(isShowingProfile ? false : true)
                
                ZStack {
                    if isShowingProfile {
                        ProfileSheet(isShowingProfile: $isShowingProfile)
                            .padding(.top, 500)
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
                    .onDelete(perform: delete)
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
                if isLoadingDundies {
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
    
    func delete(indexSet: IndexSet) {
        for (index, _) in dundies.enumerated() {
                if indexSet.contains(index) {
                    dundies[index].ckDelete { result in
                        switch result {
                            case .success:
                                print("Success")
                            case .failure(let error):
                                debugPrint("Cannot delete dundie")
                                debugPrint(error)
                        }
                    }
                }
            }
        dundies.remove(atOffsets: indexSet)
    }
    
    func recieveDundies() {
        isLoadingDundies = true
        DundieModel.ckLoadAll(then: { result in
            switch result {
                case .success(let loadedDundies):
                    self.dundies = (loadedDundies as? [DundieModel]) ?? self.dundies
                    self.dundies.sort {$0.createdAt < $1.createdAt}
                case .failure(let error):
                    debugPrint("Cannot load new messages")
                    debugPrint(error)
            }
            isLoadingDundies = false
        })
    }
    
    func onReceive(notification: CloudKitMagicCRUD.CKMNotification) {
//        if #available(iOS 15.0, *) {
////            print("New Message at \(notification.date.formatted(date: .omitted, time: .complete))")
//            print(notification.body, notification.title, notification.userID ?? "")
//        } else {
//            print("New Dundie")
//            print("New Dundie at \(notification.date)")
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
            VStack {
                if icloudUser != nil {
                    Image(uiImage: UIImage(data: (icloudUser?.profilePic!)!)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .padding(.top, -80)
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
        }
        .ignoresSafeArea()
    }
}
