
import SwiftUI
import AVFoundation
import Vision

// Definição da estrutura CameraView para integrar a visualização da câmera com a detecção de objetos
struct CameraView: NSViewRepresentable {
    // Método para criar a NSView da câmera
    func makeNSView(context: Context) -> CameraPreview {
        let preview = CameraPreview()
        return preview
    }
    
    // Método para atualizar a NSView
    func updateNSView(_ nsView: CameraPreview, context: Context) {
        // Método vazio, não há necessidade de atualizar a view
    }
}

// Classe representando a visualização da câmera
class CameraPreview: NSView, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession = AVCaptureSession()
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    private var detectionLayer: CALayer = CALayer() // Definição da detectionLayer
    private var requests: [VNRequest] = [] // Definição das requests
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
//        checkCameraPermission()
        setupCaptureSession()
        setupDetector()
    }
    
    // Método para configurar a sessão de captura de vídeo
    fileprivate func setupCaptureSession() {
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice),
              captureSession.canAddInput(input) else {
            return
        }
        
        captureSession.addInput(input)
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = bounds
        layer = previewLayer
        
        captureSession.startRunning()
        
        // Configurando a saída de vídeo para processamento de detecção
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
    }
    
    
    // Método para configurar o detector de objetos <---------------------------------------------------------------------
    fileprivate func setupDetector() {
        guard let modelURL = Bundle.main.url(forResource: "YOLOv3TinyInt8LUT", withExtension: "mlmodelc") else {
            print("Model file not found")
            return
        }
        
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let recognitionRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleDetection)
            self.requests = [recognitionRequest]  // Definindo as requests
        } catch {
            print("Error loading Core ML model:",  error)
        }
    }
    
    // Método para lidar com a detecção de objetos concluída
    fileprivate func handleDetection(request: VNRequest, error: Error?) {
        guard let results = request.results else { return }
        
        DispatchQueue.main.async {
            self.drawBoundingBoxes(results)
        }
    }
    
    // Método para desenhar as caixas delimitadoras dos objetos detectados
    fileprivate func drawBoundingBoxes(_ results: [Any]) {
        guard let previewLayer = cameraPreviewLayer else { return }
        detectionLayer.removeFromSuperlayer()
        detectionLayer = CALayer()
        detectionLayer.frame = previewLayer.frame
        
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
            
            let boundingBox = objectObservation.boundingBox
            let transformedBoundingBox = previewLayer.layerRectConverted(fromMetadataOutputRect: boundingBox)
            let boxLayer = createBoundingBoxLayer(frame: transformedBoundingBox)
            detectionLayer.addSublayer(boxLayer)
        }
        
        previewLayer.addSublayer(detectionLayer)
    }
    
    // Método para criar a camada da caixa delimitadora
    fileprivate func createBoundingBoxLayer(frame: CGRect) -> CALayer {
        let boxLayer = CALayer()
        boxLayer.frame = frame
        boxLayer.borderWidth = 2.0
        boxLayer.borderColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        return boxLayer
    }
    
    // Método delegate chamado quando um novo quadro de vídeo é capturado
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print("Error processing image request:", error)
        }
    }
}










//import SwiftUI
//import AVKit
//import AVFoundation
//
//// Struct representável para a visualização da câmera
//struct CameraView: NSViewRepresentable {
//    // Propriedade para armazenar o status da permissão da câmera
//    @State private var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
//
//    // Método para criar a NSView
//    func makeNSView(context: Context) -> CameraPreview {
//        let preview = CameraPreview()
////        preview.checkCameraPermission()
//        return preview
//    }
//
//    // Método para atualizar a NSView
//    func updateNSView(_ nsView: CameraPreview, context: Context) {
//        // Método vazio, não há necessidade de atualizar a view
//    }
//}
//
//// Classe que representa a visualização da câmera
//class CameraPreview: NSView, AVCaptureVideoDataOutputSampleBufferDelegate {
//    private var captureSession = AVCaptureSession()
//    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
//
//    override init(frame frameRect: NSRect) {
//        super.init(frame: frameRect)
//        setupCaptureSession()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // Método para configurar a sessão de captura de vídeo
//    private func setupCaptureSession() {
//        guard let captureDevice = AVCaptureDevice.default(for: .video),
//              let input = try? AVCaptureDeviceInput(device: captureDevice),
//              captureSession.canAddInput(input) else {
//            return
//        }
//
//        captureSession.addInput(input)
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.frame = bounds
//        layer = previewLayer
//
//        captureSession.startRunning()
//
//        // Configurando a saída de vídeo para processamento de detecção
//        let videoOutput = AVCaptureVideoDataOutput()
//        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
//        captureSession.addOutput(videoOutput)
//    }
//
//
//    // Método delegate chamado quando um novo quadro de vídeo é capturado
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        // Processar o buffer de amostra de vídeo aqui
//    }
//}
//
//
//
//

//
//// Método privado para verificar o status da permissão da câmera
////        public func checkCameraPermission() {
////            let status = AVCaptureDevice.authorizationStatus(for: .video)
////            self.cameraPermissionStatus = status
////        }
////
////        // Método privado para solicitar permissão de acesso à câmera
////        public func requestCameraPermission() {
////            AVCaptureDevice.requestAccess(for: .video) { granted in
////                DispatchQueue.main.async {
////                    self.cameraPermissionStatus = granted ? .authorized : .denied
////                }
////            }
////        }

