import SwiftUI

struct DundieDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var isShowingVote: Bool = false
    
    var idDundie: String
    
    @State var sortedEmployees = employees
    
    @State var votes: [DundieVote] = []
    
    @State var dicVotesEmployee: [String:Int] = [:]
    
    let dundie: DundieModel
    
    @State var isShowingView: Bool = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            Ellipse()
                .frame(width: 446, height: 402)
                .foregroundStyle(Color.ourGreen)
                .offset(y: -UIScreen.main.bounds.height/1.85)
            VStack {
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
                }
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
                    .font(Font.custom("American Typewriter", size: 25))
                    .foregroundStyle(Color.ourGreen)
                Text(dundie.descricao)
                    .font(.system(size: 16))
                    .foregroundStyle(.black)
                    .opacity(0.7)
                    .padding(.horizontal, 80)
                    .multilineTextAlignment(.center)
                Spacer()
                
                podium
                Spacer()
                listaEmployees
                    .padding(.top, 40)
                Button {
                    isShowingVote.toggle()
                } label: {
                    ZStack {
                        Text("Vote")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 123, height: 43)
                            .background(Color.ourGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                        
                }
                Spacer()
            }
            .toolbar(.hidden, for: .tabBar)
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
            recieveDundieVotes(idDundie: idDundie)
            isShowingView.toggle()
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
                        Rectangle()
                            .frame(width: 75, height: isShowingView ? 60 : 0)
                            .foregroundStyle(Color.podiumLeft)
                    }
                    .padding(.trailing, -8)
                    VStack {
                        Image(sortedEmployees[0].fotoPerfil).resizable()
                            .resizable()
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                        Rectangle()
                            .frame(width: 75, height: isShowingView ? 90 : 0)
                            .foregroundStyle(Color.podiumMiddle)
                    }
                    VStack {
                        Image(sortedEmployees[2].fotoPerfil).resizable()
                            .resizable()
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                        Rectangle()
                            .frame(width: 75, height: isShowingView ? 40 : 0)
                            .foregroundStyle(Color.podiumRight)
                    }
                    .padding(.leading, -8)
                }
            }.animation(Animation.smooth(duration: 2), value: isShowingView)
            Rectangle()
                .frame(width: 300, height: 20)
                .foregroundStyle(.gray)
                .padding(.top, -15)
        }
        .frame(height: 150)
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
                            .font(.system(size: 20))
                            .opacity(0.6)
                            .foregroundStyle(.black)
                        Spacer()
                        Text("\(dicVotesEmployee[employee.name] ?? 0)")
                            .foregroundStyle(.black)
                    }.padding(7.5)
                   
                }
            }
            .listRowBackground(Color.rowBackground)
        }
        .padding(.horizontal, 30)
        .background(.white)
        .scrollContentBackground(.hidden)
    }
    
    func recieveDundieVotes(idDundie: String) {
        DundieVote.ckLoadAll(then: { result in
            switch result {
            case .success(let loadedVotes):
                print("Entrou")
                print(loadedVotes)
                self.votes = (loadedVotes as? [DundieVote]) ?? self.votes
                // Filtrar apenas os DundieVotes com idDundie correspondente
                self.votes = self.votes.filter { $0.idDundie == idDundie }
                print(self.votes)
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
}



//#Preview {
//    DundieDetailView(titulo: "Mengo")
//}