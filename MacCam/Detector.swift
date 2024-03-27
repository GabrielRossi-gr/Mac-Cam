//import Vision
//import AVFoundation
//import SwiftUI
//
//extension CameraPreview {
//    func setupDetector() {
//        // Localização do modelo Core ML no pacote do aplicativo
//        guard let modelURL = Bundle.main.url(forResource: "YOLOv3TinyInt8LUT", withExtension: "mlmodelc") else {
//            fatalError("Model file not found")
//        }
//        
//        do {
//            // Carregando o modelo Core ML
//            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
//            // Criando uma solicitação de reconhecimento de visão com o modelo carregado
//            let recognitions = VNCoreMLRequest(model: visionModel, completionHandler: detectionDidComplete)
//            self.requests = [recognitions]
//        } catch let error {
//            print(error)
//        }
//    }
//    
//    func detectionDidComplete(request: VNRequest, error: Error?) {
//        DispatchQueue.main.async {
//            if let results = request.results {
//                // Extrair e processar as detecções
//                self.extractDetections(results)
//            }
//        }
//    }
//    
//    func extractDetections(_ results: [Any]) {
//        detectionLayer.sublayers = nil
//        
//        for observation in results where observation is VNRecognizedObjectObservation {
//            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
//            
//            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(screenRect.size.width), Int(screenRect.size.height))
//            let transformedBounds = CGRect(x: objectBounds.minX, y: screenRect.size.height - objectBounds.maxY, width: objectBounds.maxX - objectBounds.minX, height: objectBounds.maxY - objectBounds.minY)
//            
//            let boxLayer = self.drawBoundingBox(transformedBounds)
//
//            detectionLayer.addSublayer(boxLayer)
//        }
//    }
//    
//    func setupLayers() {
//        detectionLayer = CALayer()
//        detectionLayer.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
//        layer?.addSublayer(detectionLayer)
//    }
//    
//    func updateLayers() {
//        detectionLayer?.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
//    }
//    
//    func drawBoundingBox(_ bounds: CGRect) -> CALayer {
//        let boxLayer = CALayer()
//        boxLayer.frame = bounds
//        boxLayer.borderWidth = 2.0
//        boxLayer.borderColor = CGColor.init(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
//        boxLayer.cornerRadius = 2
//        return boxLayer
//    }
//    
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
//
//        do {
//            try imageRequestHandler.perform(self.requests)
//        } catch {
//            print(error)
//        }
//    }
//}