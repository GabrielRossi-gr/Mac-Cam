import SwiftUI
import AVKit


// Definindo a estrutura CameraView que implementa NSViewRepresentable para integrar a visualização da câmera no SwiftUI
struct CameraView: NSViewRepresentable {
    // Declaração de uma propriedade de estado para armazenar o status da permissão da câmera
    @State private var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    
    // Inicializador da estrutura
    init() {
        // Verifica o status da permissão da câmera ao ser inicializado
        self.checkCameraPermission()
    }
    
    // Método necessário para criar a visualização NSView
    func makeNSView(context: Context) -> NSView {
        // Cria uma NSView para exibir a visualização da câmera
        let captureView = NSView()
        
        // Inicia a captura de vídeo
        let captureSession = AVCaptureSession()
        
        // Obtém o dispositivo de captura de vídeo padrão (câmera)
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              // Cria uma instância de AVCaptureDeviceInput para alimentar a sessão de captura de vídeo
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return captureView
        }
        
        // Adiciona a entrada de vídeo à sessão de captura de vídeo
        captureSession.addInput(input)
        
        // Cria uma instância de AVCaptureVideoPreviewLayer para exibir a saída da câmera
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // Define a camada da NSView como a visualização de pré-visualização de vídeo
        captureView.layer = previewLayer
        
        // Inicia a sessão de captura de vídeo para começar a capturar imagens da câmera
        captureSession.startRunning()
        
        return captureView
    }

    // Método necessário para atualizar a visualização NSView
    func updateNSView(_ nsView: NSView, context: Context) {
        // Método vazio, não há necessidade de atualizar a visualização
    }
    
    // Método privado para verificar o status da permissão da câmera
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        self.cameraPermissionStatus = status
    }
    
    // Método privado para solicitar permissão de acesso à câmera
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraPermissionStatus = granted ? .authorized : .denied
            }
        }
    }
}

// Definindo a visualização de pré-visualização da câmera como a visualização principal no Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}





#Preview{
    CameraView()
}



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
//                self.checkCameraPermission()
//        }
