import SwiftUI
import Combine

struct LoginView: View {
    @State  var email = ""
    @State  var password = ""
    @ObservedObject  var firebaseManager:FirebaseManager
    @State private var cancellables = Set<AnyCancellable>()
    @State var showPassword: Bool = false

    var body: some View {
        NavigationView {
            VStack {

                AsyncImage(url: URL(string: "https://i.getgems.io/vj90-sDsKtOBCLjCBH7H4up2AnoX7JPFusafxZjjTPI/rs:fill:200:200:1/g:ce/czM6Ly9nZXRnZW1zLW5mdC9uZnQvYy82NWQ2MTYyMTU1Njg2NGZmMmRmYzBjMzYvYXZhdGFyLzM5ODA4MS5wbmc"))
                    .padding(.top)
                    .padding(.top)
                    .padding(.top)
                    .padding(.top)
                TextField("Почта",
                          text: $email ,
                          prompt: Text("Почта").foregroundColor(Color.gosBlue)
                )
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gosBlue, lineWidth: 2)
                }
                .padding(.horizontal)
                
                HStack {
                    Group {
                        if showPassword {
                            TextField("Пароль",
                                      text: $password,
                                      prompt: Text("Пароль").foregroundColor(Color.gosBlue))
                        } else {
                            SecureField("Пароль",
                                        text: $password,
                                        prompt: Text("Пароль").foregroundColor(Color.gosBlue))
                        }
                        
                    }
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gosBlue, lineWidth: 2)
                    }
                    Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                        }
                }.padding()
                
                Button(action: {
                    firebaseManager.loginUser(email: email, password: password)
                }) {
                    Text("Войти").foregroundStyle(.white)
                        .bold()
                }
                .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gosBlue, lineWidth: 2)
                                    .background(Color.gosBlue.cornerRadius(10))
                            }
                            .padding(.horizontal)
                Spacer()
            }
            

            .padding(.horizontal)
            

        }
    }
}
