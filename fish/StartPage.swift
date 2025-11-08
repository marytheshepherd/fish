//
//  StartPage.swift
//  fish
//
//  Created by Event on 8/11/25.
//

import SwiftUI

struct Fish: Identifiable {
    let id = UUID()
    let imageName: String
    let facingRight: Bool
}

struct StartPage: View {
    @State private var fishes = [
        Fish(imageName: "green", facingRight: true),
        Fish(imageName: "blue", facingRight: false),
    ]
    
    @State private var moveFish = false
    @State private var goNext = false
    
    
    var body: some View {
        NavigationStack{
            VStack{
//                Color.white.ignoresSafeArea()
                Spacer()
                
                Image("green").resizable().scaledToFit().offset(x:moveFish ? 400:0)
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
                    .padding(.bottom, 60)
                    
                }
                    
                
                Image("pink").resizable().scaledToFit().offset(x:moveFish ? -400:0)
                    .animation(.easeInOut(duration: 2), value:moveFish)
                
                Spacer()
                }.onAppear{
                    moveFish = false
                    goNext = false
                }
        }
    }
}


#Preview {
   StartPage()
}
