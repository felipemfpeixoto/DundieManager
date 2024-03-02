import SwiftUI

struct CreateUserView: View {
    
    @State private var name: String = ""
    
    @Binding var showFullScreen: Bool
    
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    
    var didSelect: Bool {
        selectedImage != nil
    }
    
    @State var isLoading = false
    
    var isAnimating: Bool {
        return name != "" && selectedImage != nil
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                dundieHeader
                Spacer()
                userForm
                Spacer()
                instructionText
                Spacer()
                loadingButton
                Spacer()
            }
            .padding()
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, isImagePickerPresented: $isImagePickerPresented)
            }
        }
    }
    
    var dundieHeader: some View {
        VStack {
            HStack {
                Image("DundieLogo")
                    .padding(.leading, 30)
                    .padding(.top, 50)
                    .shadow(color: .black.opacity(0.5), radius: 2.5, y: 4)
                Spacer()
            }
            Text("Welcome!")
                .padding(.leading, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.largeTitle.weight(.semibold))
            Text("I can't believe you came...")
                .padding(.leading, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title2.weight(.semibold))
            HStack {
                Spacer()
            }
        }
    }
    
    var userForm: some View {
        VStack {
            imagePickerButton
            textFieldNome
        }
        .frame(width: 330, height: 274)
        .background(Color.ourGreen)
        .clipShape(RoundedRectangle(cornerRadius: 34))
        .shadow(color: .black.opacity(0.5), radius: 2.5, y: 4)
    }
    
    var instructionText: some View {
        Text("Add a profile picture and your name to create an account")
            .foregroundStyle(Color.gray)
            .font(.footnote)
            .multilineTextAlignment(.center)
            .frame(width: 225)
    }
    
    var loadingButton: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .controlSize(.extraLarge)
            }
            else {
                sendButton
            }
        }
    }
    
    var imagePickerButton: some View {
        Button {
            isImagePickerPresented.toggle()
        } label: {
            if !didSelect {
                ZStack {
                    Circle()
                        .frame(width: 100)
                        .foregroundColor(.white)
                        // .shadow(color: .black.opacity(0.5), radius: 2.5, y: 4)
                    Image(systemName: "photo.badge.plus")
                        .font(.largeTitle)
                        .foregroundStyle(.black)
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
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .frame(height: 40)
                    .foregroundStyle(.white)
                    // .shadow(color: .black.opacity(0.5), radius: 2.5, y: 4)
                TextField("Username", text: $name)
                    .foregroundStyle(.black)
                    .font(.title3)
                    .padding()
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .frame(height: 40)
            }
        }.padding()
    }
    
    var sendButton: some View {
        ZStack {
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
                        .bold()
                }
                .opacity(isAnimating ? 1 : 0.3)
            })
            .disabled(!isAnimating)
        }
    }
    
    func send() {
        isLoading = true
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
                    icloudUser = savedUser
                    showFullScreen = false
                case .failure(let error):
                    debugPrint("Cannot Save new user")
                    debugPrint(error)
            }
        })
    }
}
