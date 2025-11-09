import SwiftUI

struct FishTankView: View {
    @Bindable var game: GameModel
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Tank background
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.25), Color.cyan.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 200)
                .cornerRadius(20)
            
            // Finish Line
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 10)
                VStack(spacing: 2) {
                    ForEach(Array("--------"), id: \.self) { letter in
                        Text(String(letter))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 10)
            }
            .offset(x: 350)
            
            // Fish overlay
            VStack(spacing: 70) {
                // Computer fish
                Image("blue")
                    .resizable()
                    .frame(width: 60, height: 30)
                    .offset(x: fishOffset(for: game.computerLevel))
                    .animation(.easeInOut(duration: 0.5), value: game.computerLevel)
                
                // Player fish
                Image("green")
                    .resizable()
                    .frame(width: 60, height: 30)
                    .offset(x: fishOffset(for: game.playerLevel))
                    .animation(.easeInOut(duration: 0.5), value: game.playerLevel)
            }
        }
        .frame(height: 200)
        .padding(.horizontal)
    }
    
    private func fishOffset(for level: Int) -> CGFloat {
        let startX: CGFloat = 10
        let stepDistance: CGFloat = 62
        return CGFloat(startX + (CGFloat(level) * stepDistance))
    }
}

