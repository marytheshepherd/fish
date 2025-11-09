import AVFoundation
import Vision
import Combine
import CoreML

final class CameraController: NSObject, ObservableObject {
    // Published value observed by SwiftUI
    @Published var detectedLabel: String = "—"
    @Published var isActive: Bool = true


    // Capture session setup
    let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "camera.video.queue")

    // Core ML model
    private lazy var gestureModel: VNCoreMLModel = {
        guard let modelURL = Bundle.main.url(forResource: "RPSImageClassifier", withExtension: "mlmodelc") else {
            fatalError("Model not found in bundle.")
        }
        let mlModel = try! MLModel(contentsOf: modelURL)
        return try! VNCoreMLModel(for: mlModel)
    }()

    // Prediction smoothing
    private var recentPredictions: [String] = []
    private var lastPredictionTime = Date()

    //Init
    override init() {
        super.init()
        setupSession()
    }

    //Camera setup
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high

        // Use the back camera
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { return }
        session.addInput(input)

        // Configure frame output
        output.setSampleBufferDelegate(self, queue: queue)
        output.alwaysDiscardsLateVideoFrames = true
        if session.canAddOutput(output) { session.addOutput(output) }

        session.commitConfiguration()
    }

    // MARK: - Control
    func start() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    func stop() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
        }
    }
}

// MARK: - Capture delegate
extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Build Vision request
        
        let request = VNCoreMLRequest(model: gestureModel) { [weak self] request, _ in
            guard let self = self,
                  let results = request.results as? [VNClassificationObservation],
                  let top = results.first else { return }

            // Perform smoothing on the camera queue (background)
            let prediction = top.identifier.lowercased()
            self.recentPredictions.append(prediction)
            if self.recentPredictions.count > 10 {
                self.recentPredictions.removeFirst()
            }

            let counts = Dictionary(grouping: self.recentPredictions, by: { $0 })
                .mapValues { $0.count }

            if let (mostCommon, count) = counts.max(by: { $0.value < $1.value }),
               count >= 7 {
                let now = Date()
                if now.timeIntervalSince(self.lastPredictionTime) > 2 {
                    self.lastPredictionTime = now
                    self.recentPredictions.removeAll()

                    // Post clean update to SwiftUI on main thread
                    DispatchQueue.main.async {
                        self.detectedLabel = mostCommon.capitalized
                    }
                }
            }
        }

        // Run Vision model off the main thread
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
                try? handler.perform([request])
            }
        }

