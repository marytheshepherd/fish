import AVFoundation
import Vision
import Combine
import CoreML

final class CameraController: NSObject, ObservableObject {
    let session = AVCaptureSession()
    @Published var detectedLabel: String = "—"

    private let output = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "camera.video.queue")
   
    
    //my ML Model_trained
    private lazy var gestureModel: VNCoreMLModel = {
        guard let modelURL = Bundle.main.url(forResource: "RPSImageClassifier", withExtension: "mlmodelc") else {
            fatalError("Model not found in bundle.")
        }

        let mlModel = try! MLModel(contentsOf: modelURL)
        return try! VNCoreMLModel(for: mlModel)
    }()


    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { return }
        session.addInput(input)

        output.setSampleBufferDelegate(self, queue: queue)
        output.alwaysDiscardsLateVideoFrames = true
        if session.canAddOutput(output) { session.addOutput(output) }

        session.commitConfiguration()
    }

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

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        //Vision request using model
        let request = VNCoreMLRequest(model: gestureModel) { request, _ in
            if let results = request.results as? [VNClassificationObservation],
               let top = results.first {
                DispatchQueue.main.async {
                    // UI predicted label
                    self.detectedLabel = top.identifier.capitalized
                }
            }
        }
        request.imageCropAndScaleOption = .scaleFit

        //Running on current frame
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        try? handler.perform([request])
    }
}

