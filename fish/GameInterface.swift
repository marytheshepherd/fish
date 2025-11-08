import SwiftUI

struct GameInterface: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Text("Scissors Paper Stone")
                .font(.largeTitle)
                .foregroundColor(.black)
        }
    }
}

