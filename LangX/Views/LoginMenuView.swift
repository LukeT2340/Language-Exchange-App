//
import SwiftUI
import Firebase

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
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity)
                .buttonStyle()
                
                
                // Continue with Google
                Button(action: {
                    // Handle Google Sign In
                }) {
                    HStack {
                        Image("googleIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Spacer()
                        
                        
                        Text(NSLocalizedString("Use-Google-Button", comment: "Sign in with google"))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Spacer()
                        
                        Image("googleIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .hidden()
                        
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle()
                }
                // Continue with Apple
                Button(action: {
                }) {
                    HStack {
                        Image(systemName: "applelogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(NSLocalizedString("Use-Apple-Button", comment: "Sign in with apple"))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Spacer()
                        
                        Image(systemName: "applelogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .hidden()
                        
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle()
                    
                }
                
                // Continue with WeChat
                Button(action: {
                    // Handle WeChat Sign In
                }) {
                    HStack {
                        Image("wechatIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Spacer()
                        
                        Text(NSLocalizedString("Use-WeChat-Button", comment: "Sign in with wechat"))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        
                        Spacer()
                        
                        Image("wechatIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .hidden()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle()
                    
                }
                
                // Continue with Email
                NavigationLink(destination: LoginView().environmentObject(authManager)) {
                    Image(systemName: "envelope.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Spacer()
                    
                    Text(NSLocalizedString("Use-Email-Button", comment: "Sign in with email"))
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                    
                    Image(systemName: "envelope.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .hidden()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle()
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                colorScheme == .dark ?
                    LinearGradient(gradient: Gradient(colors: [Color(red: 0.22, green: 0.22, blue: 0.24), Color(red: 0.28, green: 0.28, blue: 0.30)]), startPoint: .top, endPoint: .bottom) :
                    LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.95, blue: 0.98), Color(red: 0.88, green: 0.88, blue: 0.92)]), startPoint: .top, endPoint: .bottom)
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

