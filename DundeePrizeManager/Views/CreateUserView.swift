import SwiftUI

struct CreateUserView: View {
    
    @State private var name: String = ""
    
    @Binding var showFullScreen: Bool
    
    @State var didSelect: Bool = false
    
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                Spacer()
                Text("Crie uma conta para prosseguir")
                    .font(Font.custom("American Typewriter", size: 25))
                    .foregroundStyle(.black)
                Spacer()
                imagePickerButton
                Spacer()
                textFieldNome
                Spacer()
                sendButton
                Spacer()
            }
            .padding()
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, isImagePickerPresented: $isImagePickerPresented)
            }
        }
    }
    
    var imagePickerButton: some View {
        Button {
            isImagePickerPresented.toggle()
            didSelect = true
        } label: {
            if !didSelect {
                ZStack {
                    Circle()
                        .frame(width: 100)
                        .foregroundColor(Color(hex: "D9D9D9"))
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 30))
                        .foregroundStyle(.black)
                }
            } else {
                Image(uiImage: selectedImage ?? UIImage(systemName: "photo")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
        }.padding()
    }
    
    var textFieldNome: some View {
        VStack(alignment: .leading) {
            Text("Nome:")
                .font(Font.custom("American Typewriter", size: 20))
                .foregroundStyle(.black)
                .opacity(0.6)
                .padding(.leading)
                .padding(.bottom, -10)
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .frame(height: 40)
                    .foregroundStyle(Color(hex: "D9D9D9"))
                TextField("", text: $name)
                    .foregroundStyle(.black)
                    .font(.system(size: 20))
                    .padding()
            }
        }.padding()
    }
    
    var sendButton: some View {
        Button(action: {
            send()
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 123, height: 43)
                    .foregroundStyle(Color(hex: "85A2A0"))
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
                    .font(.system(size: 23))
                    .bold()
            }
        })
    }
    
    func send() {
        let nameFinal = name
        
        guard
            let image = selectedImage ?? UIImage(named: "avatar-padrao"),
            let data = image.jpegData(compressionQuality: 1.0)
        else { return }
        
        let newUser = DundieUser(icloudID: dao.userID?.recordName ?? "Nome nao inserido", profilePic: data, userName: nameFinal)
        
        newUser.ckSave(then: { result in
            switch result {
                case .success(let savedUser):
                    guard let savedUser = savedUser as? DundieUser else {return}
                    print(savedUser)
                    showFullScreen = false
                case .failure(let error):
                    debugPrint("Cannot Save new user")
                    debugPrint(error)
            }
        })
    }
}
