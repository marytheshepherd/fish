import SwiftUI

struct Fish: Identifiable {
    let id = UUID()
    let imageName: String
    let facingRight: Bool
}

struct ContentView: View {
    
    @State private var moveFish = false
    @State private var goNext = false
    
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.white.ignoresSafeArea()
                VStack{
                    Spacer()
                    
                    Image("green").resizable().scaledToFit().offset(x:moveFish ? 500:0)
                        .animation(.easeInOut(duration: 2), value:moveFish)
                    
                    Button(action: {
                        withAnimation {
                            moveFish = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            goNext = true
                        }
                    }) {
                        Text("Start")
                            .font(.title.bold())
                            .padding(.horizontal, 40)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        
                    }
                    .navigationDestination(isPresented: $goNext) {
                        GameInterface()
                        
                    }
                    
                    
                    Image("pink").resizable().scaledToFit().offset(x:moveFish ? -500:0)
                        .animation(.easeInOut(duration: 2), value:moveFish)
                    
                    Spacer()
                }.onAppear{
                    moveFish = false
                    goNext = false
                }
            }
        }
    }
}


#Preview {
    ContentView()
}


