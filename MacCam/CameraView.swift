import SwiftUI
import AVKit

struct CameraView: NSViewRepresentable {
    @State private var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined

    
    init() {
        self.checkCameraPermission()
    }
    
    
    func makeNSView(context: Context) -> NSView {
        let captureView = NSView()
        
        // Start capturing video
        let captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return captureView
        }
        
        captureSession.addInput(input)
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        captureView.layer = previewLayer
        captureSession.startRunning()
        
        return captureView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // Update the view
    }
    
    
    
    //check permission
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        self.cameraPermissionStatus = status
    }
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraPermissionStatus = granted ? .authorized : .denied
            }
        }
    }
}








//
//import SwiftUI
//import AVFoundation
//
//struct CameraaView: View {
//    @State private var isShowingCamera = false
//    @State private var captureSession: AVCaptureSession?
//    @State private var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
//
//    
//    init(){
//        self.checkCameraPermission()
//    }
//    
//    
//    var body: some View {
//        VStack {
//            if isShowingCamera {
////                CameraaPreview(session: captureSession)
//            } else {
//                Button("Abrir Câmera") {
//                    self.setupCamera()
//                }
//            }
//
//            switch cameraPermissionStatus {
//                        case .authorized:
//                            Text("Permissão concedida para acessar a câmera.")
//                
//                        case .notDetermined:
//                            Button("Permitir Acesso à Câmera") {
//                                self.requestCameraPermission()
//                            }
//                        default:
//                            Text("Acesso à câmera negado. Você pode alterar isso nas configurações do aplicativo.")
//                        }
//                    }
//            .onAppear {
////                self.checkCameraPermission()
////            .onDisappear {
////                self.stopCamera()
//        }
//    }
//    
//    //run camera
//    private func setupCamera() {
//        self.captureSession = AVCaptureSession()
//
//        guard let camera = AVCaptureDevice.default(for: .video) else {
//            print("No video camera available")
//            return
//        }
//
//        do {
//            let input = try AVCaptureDeviceInput(device: camera)
//            self.captureSession?.addInput(input)
//        } catch {
//            print(error.localizedDescription)
//            return
//        }
//
//               
//        self.isShowingCamera = true
//        self.captureSession?.startRunning()
//    }
//
//    private func stopCamera() {
//        self.captureSession?.stopRunning()
//    }
//    
//
//    
////    //check permission
////    private func checkCameraPermission() {
////        let status = AVCaptureDevice.authorizationStatus(for: .video)
////        self.cameraPermissionStatus = status
////    }
////    private func requestCameraPermission() {
////        AVCaptureDevice.requestAccess(for: .video) { granted in
////            DispatchQueue.main.async {
////                self.cameraPermissionStatus = granted ? .authorized : .denied
////            }
////        }
////    }
//}
//
