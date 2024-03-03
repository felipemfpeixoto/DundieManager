import SwiftUI

struct VoteView: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State var votedUser: DundieVote = DundieVote(idVotador: "", idVotante: "", idDundie: "")
    
    private let adaptiveColumns = [
            GridItem(.adaptive(minimum: 70)),
            GridItem(.adaptive(minimum: 70)),
            GridItem(.adaptive(minimum: 70))
        ]
    
    let idDundie: String
    
    @Binding var isShowing: Bool
    
    var votes: [DundieVote]
    
    @State var isLoadingVote: Bool = false
    
    var body: some View {
        ZStack {
            Color.ourGreen
                .ignoresSafeArea()
            VStack {
                dismissButton
                Spacer()
                Text("Select a Person to Vote")
                    .font(.custom("American Typewriter", size: 22, relativeTo: .title2))
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                Spacer()
                grid
                Spacer()
                if isLoadingVote {
                   ProgressView()
                        .controlSize(.extraLarge)
                }
                else {
                    sendVoteButton
                }
                Spacer()
            }
        }
        .task {
            verificaVotos()
        }
    }
    
    var dismissButton: some View {
        HStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.white)
                    .font(.title.weight(.semibold))
            }
            .padding()
            Spacer()
        }
    }
    
    var grid: some View {
        LazyVGrid(columns: adaptiveColumns, spacing: 50) {
            ForEach(employees) { employee in
                ZStack {
                    Circle()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(Color.ourGreen)
                        .shadow(color: .black.opacity(0.5), radius: 2.5)
                    Button {
                        votedUser = DundieVote(idVotador: dao.userID?.recordName ?? "", idVotante: employee.name, idDundie: idDundie)
                    } label: {
                        Image(employee.fotoPerfil)
                            .resizable()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                    }
                    .opacity(votedUser.idVotante == employee.name ? 0.3 : 1)
                }
            }
        }
    }
    
    var sendVoteButton: some View {
        Button{
            for vote in votes {
                if vote.idVotador == dao.userID?.recordName {
                    votedUser.recordName = vote.recordName
                }
            }
            sendVote(vote: votedUser)
        } label: {
            Image(systemName: "checkmark")
                .font(.title2.weight(.medium))
                .foregroundStyle(Color.ourGreen)
                .frame(width: 123, height: 43)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.5), radius: 2.5, y: 4)
        }
    }
    
    func verificaVotos() {
        for voto in votes {
            if voto.idVotador == icloudUser?.icloudID {
                votedUser = voto
            }
        }
    }
    
    func sendVote(vote: DundieVote) {
        isLoadingVote = true
        if vote.idVotador != "" && vote.idVotante != "" {
            vote.ckSave(then: { result in
                switch result {
                case .success(let savedVote):
                    guard let savedVote = savedVote as? DundieVote else {return}
                    print(savedVote)
                    isShowing = false
                case .failure(let error):
                    debugPrint("Cannot Save new dundie")
                    debugPrint(error)
                }
            })
        } else {
            return;
        }
    }
}
