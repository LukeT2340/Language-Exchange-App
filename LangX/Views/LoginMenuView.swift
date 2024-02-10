//
import SwiftUI
import Firebase
import _AuthenticationServices_SwiftUI
import GoogleSignInSwift

struct LoginMenuView_Previews: PreviewProvider {
    static var previews: some View {
        LoginMenuView().environmentObject(AuthManager())
    }
}

struct LoginMenuView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 15) {
                Spacer()
                HStack {
                    Image("Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .opacity(isAnimating ? 1.0 : 0.8)
                        .onAppear() {
                            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                isAnimating.toggle()
                            }
                        }
                    
                    Text(NSLocalizedString("App-Name", comment: "App name"))
                        .font(.system(size: 45, weight: .bold, design: .rounded))
                        .foregroundColor(Color.primary)
                }
                
                Spacer()
                
                // Sign-up with Email
                NavigationLink(destination: EmailSignUpView().environmentObject(authManager)) {
                    Text(NSLocalizedString("Create-Account-Button", comment: "Sign up"))
                }
                .padding(8)
                .frame(width: 300, height: 50)
                .background(Color(red: 51/255, green: 150/255, blue: 255/255))
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.system(size: 19))
                
                // Continue with Email
                NavigationLink(destination: LoginView().environmentObject(authManager)) {
                    HStack {
                        Spacer()
                        Image(systemName: "envelope.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        
                        Text(NSLocalizedString("Use-Email-Button", comment: "Sign in with email"))
                        
                        Spacer()
                    }
                }
                .padding(8)
                .frame(width: 300, height: 50)
                .background(Color(red: 51/255, green: 150/255, blue: 255/255))
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.system(size: 19))

                Button(action: {authManager.sendVerificationCode(phoneNumber: "+61493259922")}) {
                    Text("Mobile Sign in")
                }
                
                Button(action: {
                    guard let rootViewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                        print("Unable to find a root view controller.")
                        return
                    }
                    authManager.signInWithGoogle(presentingViewController: rootViewController)
                }) {
                    HStack (alignment: .center) {
                        Image("googleIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        
                        Text(NSLocalizedString("Use-Google-Button", comment: "Sign in with google"))
                            .foregroundColor(.black)
                    }
                    .padding(8)
                    .frame(width: 300, height: 50)
                    .background(Color.white)
                    .cornerRadius(8)
                    .font(.system(size: 19))
                }
                
                // Continue with Apple
                Button(action: {
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "applelogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        
                        Text(NSLocalizedString("Use-Apple-Button", comment: "Sign in with apple"))
                        Spacer()
                    }
                    .padding(8)
                    .frame(width: 300, height: 50)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .font(.system(size: 19))
                    
                }
                
                // WeChat Sign-In Button
                Button(action: {

                }) {
                    HStack (alignment: .center) {
                        Image("wechatIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text(NSLocalizedString("Use-Wechat-Button", comment: "Sign in with wechat"))
                            .foregroundColor(.white)
                    }
                    .padding(8)
                    .frame(width: 300, height: 50)
                    .background(Color(red: 45/255, green: 193/255, blue: 0))
                    .cornerRadius(8)
                    .font(.system(size: 19))
                }
            

                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme == .light ?
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.98, blue: 1.00), // Very light pastel blue
                        Color(red: 0.85, green: 0.90, blue: 0.95)  // Slightly deeper pastel blue
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ) : LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.18, green: 0.23, blue: 0.28), // Slightly lighter dark slate blue
                        Color(red: 0.28, green: 0.33, blue: 0.38)  // A bit lighter and softer slate blue
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .accentColor(Color(red: 0.39, green: 0.58, blue: 0.93))
        .onAppear(perform:
                self.hideKeyboard
        )
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

