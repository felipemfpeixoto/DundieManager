import SwiftUI
import CloudKitMagicCRUD

struct DundieDetailView: View, CKMRecordObserver {
    @Environment(\.dismiss) var dismiss
    
    @State var isShowingVote: Bool = false
    
    var idDundie: String
    
    @Binding var isShowingProfile: Bool
    
    @State var sortedEmployees = employees
    
    @State var votes: [DundieVote] = []
    
    @State var dicVotesEmployee: [String:Int] = [:]
    
    let dundie: DundieModel
    
    @State var isShowingView: Bool = false
    
    @State var isLoadingVotes: Bool = false
    
    var body: some View {
        ZStack {
            dundieBackground
            VStack {
                backButton
                dundieInfo
                Spacer()
                VStack {
                    if isLoadingVotes {
                       ProgressView()
                            .controlSize(.extraLarge)
                    }
                    else {
                        podium
                        Spacer()
                        listaEmployees
                        Spacer()
                        voteButton
                    }
                }
              
                Spacer()
            }
            .sheet(isPresented: $isShowingVote, content: {
                VoteView(idDundie: idDundie, isShowing: $isShowingVote, votes: votes)
            })
            .onChange(of: isShowingVote) { newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    recieveDundieVotes(idDundie: idDundie)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            isShowingProfile = false
            recieveDundieVotes(idDundie: idDundie)
        }
//        .onAppear {
//            CKMDefault.notificationManager.createNotification(to:self, for: DundieVote.self) {
//                        result in
//                        switch result {
//                            case .success( _):
//                            print("Pegou")
//                                break
//                            case .failure(let error):
//                                debugPrint(error)
//                        }
//                    }
//            DundieVote.register(observer: self)
//
//            print("Registrei!")
//        }
    }
    
    var dundieBackground: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            Ellipse()
                .frame(width: 446, height: 402)
                .foregroundStyle(Color.ourGreen)
                .offset(y: -UIScreen.main.bounds.height/1.85)
        }
    }
    
    var backButton: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.black)
                    .font(.title.weight(.semibold))
            }
            .padding(.horizontal, 40)
            Spacer()
            Button {
                recieveDundieVotes(idDundie: idDundie)
            } label: {
                Image(systemName: "arrow.clockwise")
                    .foregroundStyle(.black)
                    .font(.title.weight(.semibold))
            }
            .padding(.horizontal, 40)
        }
    }
    
    var dundieInfo: some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 90, height: 90)
                    .foregroundStyle(.white)
                Image(uiImage: UIImage(data: dundie.dundieImage ?? Data()) ?? UIImage(systemName: "person.circle.fill")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
            }
            .padding(.top, 30)
            Text(dundie.dundieName)
                .font(.custom("American Typewriter", size: 25, relativeTo: .title2).weight(.semibold))
                .foregroundStyle(Color.ourGreen)
            Text(dundie.descricao)
                .font(.callout)
                .foregroundStyle(.black)
                .opacity(0.7)
                .padding(.horizontal, 80)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)
        }
    }
    
    var podium: some View {
        VStack {
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    VStack {
                        Image(sortedEmployees[1].fotoPerfil).resizable()
                            .resizable()
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.5), radius: 2.5, x: 2, y: 4)
                        Rectangle()
                            .frame(width: 75, height: isShowingView ? 60 : 0)
                            .foregroundStyle(Color.podiumLeft)
                            .shadow(color: .black.opacity(0.5), radius: 2.5, x: 2, y: 4)
                    }
                    .padding(.trailing, -8)
                    VStack {
                        Image(sortedEmployees[0].fotoPerfil).resizable()
                            .resizable()
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.5), radius: 2.5, x: 2, y: 4)
                        Rectangle()
                            .frame(width: 75, height: isShowingView ? 90 : 0)
                            .foregroundStyle(Color.podiumMiddle)
                            .shadow(color: .black.opacity(0.5), radius: 2.5, x: 2, y: 4)
                    }
                    VStack {
                        Image(sortedEmployees[2].fotoPerfil).resizable()
                            .resizable()
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.5), radius: 2.5, x: 2, y: 4)
                        Rectangle()
                            .frame(width: 75, height: isShowingView ? 40 : 0)
                            .foregroundStyle(Color.podiumRight)
                            .shadow(color: .black.opacity(0.5), radius: 2.5, x: 2, y: 4)
                    }
                    .padding(.leading, -8)
                }
            }
            .animation(Animation.smooth(duration: 2), value: isShowingView)
            .animation(.easeInOut, value: isLoadingVotes) // nao ta funcionando
            Rectangle()
                .frame(width: 300, height: 20)
                .foregroundStyle(.gray)
                .padding(.top, -15)
                .shadow(color: .black.opacity(0.5), radius: 2.5, x: 2, y: 4)
        }
        .frame(height: 150)
        .padding(.bottom, 10)
    }
    
    var listaEmployees: some View {
        List {
            Section("") {
                ForEach(sortedEmployees) { employee in
                    HStack {
                        Image(employee.fotoPerfil)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                        Text(employee.name)
                            .font(.title3)
                            .opacity(0.6)
                            .foregroundStyle(.black)
                        Spacer()
                        Text("\(dicVotesEmployee[employee.name] ?? 0)")
                            .foregroundStyle(.black)
                    }
                    .padding(7.5)
                }
            }
            .listRowBackground(Color.white)
        }
        .padding(.horizontal, 30)
        .background(.white)
        .scrollContentBackground(.hidden)
    }
    
    var voteButton: some View {
        Button {
            isShowingVote.toggle()
        } label: {
            ZStack {
                Text("Vote")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 123, height: 43)
                    .background(Color.ourGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
    
    func recieveDundieVotes(idDundie: String) {
        isLoadingVotes = true
        isShowingView = false
        DundieVote.ckLoadAll(then: { result in
            switch result {
            case .success(let loadedVotes):
                self.votes = (loadedVotes as? [DundieVote]) ?? self.votes
                // Filtrar apenas os DundieVotes com idDundie correspondente
                self.votes = self.votes.filter { $0.idDundie == idDundie }
                dicVotesEmployee = [:]
                for vote in self.votes {
                    if dicVotesEmployee[vote.idVotante] != nil {
                        dicVotesEmployee[vote.idVotante]! += 1
                    } else {
                        dicVotesEmployee[vote.idVotante] = 1
                    }
                }
                completaDic()
                ordenaLista()
                isLoadingVotes = false
                DispatchQueue.main.async {
                    isShowingView = true
                }
            case .failure(let error):
                debugPrint("Cannot load new dundies")
                debugPrint(error)
            }
        })
    }
    
    func completaDic() {
        for employee in employees {
            if !dicVotesEmployee.keys.contains(employee.name) {
                dicVotesEmployee[employee.name] = 0
            }
        }
    }
    
    func ordenaLista() {
        sortedEmployees = sortedEmployees.sorted { (elemento1, elemento2) -> Bool in
            guard let indice1 = dicVotesEmployee[elemento1.name],
                  let indice2 = dicVotesEmployee[elemento2.name] else {
                    return false
                }
                return indice1 > indice2
            }
    }
    
    func onReceive(notification: CloudKitMagicCRUD.CKMNotification) {
//        print("New Message at \(notification.date.formatted(date: .omitted, time: .complete))")
//
//        if #available(iOS 15.0, *) {
//            print("New Message at \(notification.date.formatted(date: .omitted, time: .complete))")
//            print(notification.body, notification.title, notification.userID ?? "")
//        } else {
//            print("New Dundie")
//            print("New Dundie at \(notification.date)")
//        }
        recieveDundieVotes(idDundie: idDundie)
    }
}
