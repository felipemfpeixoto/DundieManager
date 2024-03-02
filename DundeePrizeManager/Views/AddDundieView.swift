import SwiftUI
import CloudKit

struct AddDundieView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    
    @State private var descricao: String = ""
    
    @State private var emoji: String = "🙈"
    
    @Binding var dundies: [DundieModel]
    
    @Binding var isShowing: Bool
    
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    
    var didSelect: Bool {
        selectedImage != nil
    }
    
    @State var isLoading = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                header
                imagePickerButton
                textFieldNome
                textFieldDescricao
                Spacer()
                if isLoading {
                   ProgressView()
                        .controlSize(.extraLarge)
                }
                else {
                    sendButton
                }
                Spacer()
            }
            .padding()
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, isImagePickerPresented: $isImagePickerPresented)
            }
        }
    }
    
    var header: some View {
        VStack {
            HStack {
                Button(action: {
//                    dismiss()
                    isShowing.toggle()
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title)
                })
                .foregroundStyle(.black)
                .font(.largeTitle)
                .padding(20)
                Spacer()
            }
            Text("Novo Dundie")
                .font(.custom("American Typewriter", size: 31, relativeTo: .title3))
                .fontWeight(.medium)
                .foregroundStyle(.black)
                .padding(.bottom)
        }
    }
    
    var imagePickerButton: some View {
        Button {
            isImagePickerPresented.toggle()
        } label: {
            if !didSelect {
                ZStack {
                    Image(systemName: "photo.badge.plus")
                        .font(.title)
                        .foregroundStyle(.black)
                        .frame(width: 100, height: 100)
                        .background(Color.ourGray)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.5), radius: 2.5, y: 4)
                }
            } else {
                Image(uiImage: selectedImage ?? UIImage(systemName: "photo")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.5), radius: 2.5, y: 4)
            }
        }.padding()
    }
    
    var textFieldNome: some View {
        VStack(alignment: .leading) {
            Text("Nome:")
                .font(.custom("American Typewriter", size: 20, relativeTo: .title3))
                .foregroundStyle(.black)
                .opacity(0.6)
                .padding(.leading)
                .padding(.bottom, -10)
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .frame(height: 40)
                    .foregroundStyle(Color.ourGray)
                    .shadow(color: .black.opacity(0.5), radius: 2.5, y: 4)
                TextField("", text: $name)
                    .foregroundStyle(.black)
                    .font(.system(size: 20))
                    .padding()
            }
        }.padding()
    }
    
    var textFieldDescricao: some View {
        VStack(alignment: .leading) {
            Text("Descrição:")
                .font(.custom("American Typewriter", size: 20, relativeTo: .title3))
                .foregroundStyle(.black)
                .opacity(0.6)
                .padding(.leading)
            // Esse text Field precisa estar em cima, e fazer o wrap para a linha de baixo ao chegar na margem do retangulo
            // Talvez adicionar um contador de caracteres, com máximo de 255
            // Caso texto com o wrap fique com altura maior do q o retangulo, fazer uma scrollview
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .frame(height: 140)
                    .foregroundStyle(Color.ourGray)
                    .shadow(color: .black.opacity(0.5), radius: 2.5, y: 4)
                TextField("", text: $descricao)
                    .foregroundStyle(.black)
                    .font(.title3)
                    .padding()
                    .frame(height: 140)
            }
        }
        .padding()
    }
    
    var sendButton: some View {
        Button(action: {
            send()
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 123, height: 43)
                    .foregroundStyle(Color.ourGreen)
                    .shadow(color: .black.opacity(0.5), radius: 2.5, y: 4)
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .bold()
            }
        })
    }
    
    func send() {
        isLoading = true
        let nameFinal = name
        let descricaoFinal = descricao
        
        guard 
            let image = selectedImage ?? UIImage(named: "avatar-padrao"),
            let data = image.jpegData(compressionQuality: 1.0)
        else { return }
        
        let newDundie = DundieModel(emoji: emoji, dundieImage: data, dundieName: nameFinal, descricao: descricaoFinal)
        
        newDundie.ckSave(then: { result in
            switch result {
                case .success(let savedDundie):
                    guard let savedDundie = savedDundie as? DundieModel else {return}
                    self.dundies.append(savedDundie)
                    print(savedDundie)
                    isShowing.toggle()
                case .failure(let error):
                    debugPrint("Cannot Save new dundie")
                    debugPrint(error)
            }
        })
    }
}

//#Preview {
//    AddDundieView(dundies: Binding<[DundieModel]>, isShowing: <#Binding<Bool>#>)
//}
