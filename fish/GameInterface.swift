import SwiftUI

struct GameInterface: View {
    @StateObject private var camera = CameraController()

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()
            
            // Hand Gesture Detected
            Text(camera.detectedLabel)
                .font(.title2).bold()
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.black.opacity(0.6))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding(.bottom, 40)
        }
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
    }
}

