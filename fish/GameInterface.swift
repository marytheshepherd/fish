import SwiftUI

struct GameInterface: View {
    @StateObject private var camera = CameraController()
    @State private var game = GameModel()
    @State private var streak = StreakCounter()


    // Countdown states
    @State private var countdownTimer: Timer? = nil
    @State private var showCountdown = false
    @State private var countdownValue = 4
    @State private var lastGestureTime = Date()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea(edges: .all)
            VStack(spacing: 30) {
    
                Text("Highest streak achieved: \(streak.highestStreak)")
                    .font(.headline).foregroundColor(.black)
                Text("Current streak: \(game.currentStreak)")
                    .font(.subheadline).foregroundColor(.black)

                //Camera preview
                CameraPreview(session: camera.session)
                    .frame(height: 250)
                    .cornerRadius(16)
                    .overlay(alignment: .bottomTrailing) {
                        Text(camera.detectedLabel)
                            .font(.title2.bold())
                            .padding(8)
                            .background(.black.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding()
                    }
                    .onAppear { camera.start() }
                    .onDisappear { camera.stop() }

                // Fish race display
                FishTankView(game: game)
                

                // Result
                Text(game.result)
                    .font(.title3.bold())
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                

                if game.showResetMessage {
                    Text("🏁 New Round Starting...")
                        .font(.callout)
                        .foregroundColor(.black)
                        .onChange(of: game.showResetMessage) { _, isRestarting in
                            camera.isActive = !isRestarting
                        }

                }
            }
      

            // Countdown overlay
            if showCountdown {
                ZStack{
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    Text(countdownText)
                        .font(.system(size: 70, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(1.2)
                        .transition(.opacity.combined(with: .scale))
                        .id(countdownText)
                        .animation(.easeInOut(duration: 0.3), value: countdownText)
                }
            }
        }
        // ML-detected gestures
        .onChange(of: camera.detectedLabel) { _, newGesture in
            startCountdown(for: newGesture)
        }
        // restarting
        .onChange(of: game.showResetMessage) { _, isRestarting in
            camera.isActive = !isRestarting
            if isRestarting {
                countdownTimer?.invalidate()
                countdownTimer = nil
                showCountdown = false
                streak.updateHighestStreak(currentStreak: game.currentStreak)
            }
        }

    }

    //Countdown Logic

    private func startCountdown(for gesture: String) {
        let validGestures = ["rock", "paper", "scissors"]
        guard validGestures.contains(gesture.lowercased()) else { return }

        //cancel any existing timer before starting a new one
        countdownTimer?.invalidate()
        countdownTimer = nil

        showCountdown = true
        countdownValue = 4

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            countdownValue -= 1

            // Stop at zero
            if countdownValue == 0 {
                timer.invalidate()
                countdownTimer = nil
                showCountdown = false
                handleGesture(gesture)
            }
        }
    }
    
    private var countdownText: String {
        switch countdownValue {
        case 4:
            return "Hold"
        case 1...3:
            return "\(countdownValue)"
        default:
            return "GO!"
        }
    }

    // MARK: - Gesture → Play mapping
    private func handleGesture(_ gesture: String) {
        switch gesture.lowercased() {
        case "rock":
            game.play("✊")
        case "paper":
            game.play("✋")
        case "scissors":
            game.play("✌️")
        default:
            break
        }
    }
}

