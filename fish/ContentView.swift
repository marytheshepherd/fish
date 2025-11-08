//
//  ContentView.swift
//  fish
//
//  Created by Event on 8/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{
            LinearGradient(
                colors: [.clear, .blue.opacity(0.3)],
                startPoint: .top,
                endPoint: .center
            ).ignoresSafeArea()
            VStack {
                Spacer()
                Button(
                    action:{}
                ){
                    Image("pink").resizable()
                        .scaledToFit()
                        .foregroundColor(Color.red)}

                Spacer()
                Button(
                    action:{}
                ){
                    Image("green").resizable()
                        .scaledToFit()
                        .foregroundColor(Color.red)}
                Spacer()

//                Button(action: {
//                            print("")
//                        }) {
//                            Image(systemName: "fish")
//                                .font(.system(size: 50))
//                                .foregroundColor(Color.red)
//                                .rotationEffect(Angle(degrees:-90))
//                        }
                
            }
        }
        
    }
}



#Preview {
   ContentView()
}


