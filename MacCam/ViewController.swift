//
//  ViewController.swift
//  MacCam
//
//  Created by Gabriel Rossi on 27/03/24.
//


import AppKit
import SwiftUI
import AVFoundation
import Vision

// ViewController que gerencia a captura de vídeo e detecção de objetos
class ViewController: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // Flag para verificar se a permissão foi concedida
    private var permissionGranted = false
    // Sessão de captura de vídeo
    private let captureSession = AVCaptureSession()
    // Fila de sessão para operações relacionadas à sessão de captura
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    // Camada de pré-visualização do vídeo
    private var previewLayer = AVCaptureVideoPreviewLayer()
    
    // Retângulo de tela para dimensões da visualização
    var screenRect: CGRect! = nil
    
    // Saída de vídeo para processamento de detecção
    private var videoOutput = AVCaptureVideoDataOutput()
    
    // Solicitações de visão para detecção de objetos
    var requests = [VNRequest]()
    // Camada de detecção para sobreposição de objetos detectados
    var detectionLayer: CALayer! = nil

    
    
//    init(screenSize: CGRect){
//        self.screenRect = screenSize
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    
    // Método chamado quando a visualização é carregada
    override func viewDidLoad() {
        // Verificar permissão da câmera
        checkPermission()
        
        // Inicializar a sessão de captura em uma fila separada
        sessionQueue.async { [unowned self] in
            // Só configurar a sessão se a permissão for concedida
            guard permissionGranted else { return }
            // Configurar a sessão de captura
            self.setupCaptureSession()
            
            // Configurar as camadas para visualização e detecção
            self.setupLayers()
            // Configurar o detector de objetos
            self.setupDetector()
            
            // Iniciar a sessão de captura de vídeo
            self.captureSession.startRunning()
        }
    }
    
    // Método chamado quando a visualização aparece novamente
    override func viewDidAppear() {
        screenRect = NSScreen.main?.frame
//        self.previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)

        self.setupLayers()
    }

    
    // Método para verificar permissão da câmera
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            // Permissão concedida anteriormente
            case .authorized:
                permissionGranted = true
                
            // Permissão ainda não solicitada
            case .notDetermined:
                requestPermission()
                    
            default:
                permissionGranted = false
            }
    }
    
    // Método para solicitar permissão da câmera
    func requestPermission() {
        // Suspender a fila de sessão enquanto a permissão está sendo solicitada
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            // Resumir a fila de sessão quando a permissão for concedida ou negada
            self.sessionQueue.resume()
        }
    }
    
    
    
    
    
    // Método para configurar a sessão de captura de vídeo <--------------------------------------------------------------------------------------------------
    func setupCaptureSession() {
        // Entrada de vídeo da câmera
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice),
              captureSession.canAddInput(input) else {
            return
        }
           
        captureSession.addInput(input)
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
                     
        // Obtendo o tamanho da camada de visualização
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        
//        let previewLayerSize = CGSize(width: 400, height: 300) // Define o tamanho conforme necessário
//        previewLayer.frame = CGRect(origin: .zero, size: previewLayerSize)
        
        
        // Adicionando a camada de pré-visualização à camada da view
        view.layer = previewLayer
        captureSession.startRunning()

        // Configurando a saída de vídeo para processamento de detecção
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
    }
}



extension ViewController {
    
    // Método para configurar o detector de objetos
    func setupDetector() {
        // Localização do modelo Core ML no pacote do aplicativo
        let modelURL = Bundle.main.url(forResource: "YOLOv3TinyInt8LUT", withExtension: "mlmodelc")
        
        do {
            // Carregando o modelo Core ML
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL!))
            // Criando uma solicitação de reconhecimento de visão com o modelo carregado
            let recognitions = VNCoreMLRequest(model: visionModel, completionHandler: detectionDidComplete)
            self.requests = [recognitions]
        } catch let error {
            print(error)
        }
    }
    
    // Método chamado quando a detecção de objetos é concluída
    func detectionDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async(execute: {
            if let results = request.results {
                // Extrair e processar as detecções
                self.extractDetections(results)
            }
        })
    }
    
    // Método para extrair e processar as detecções
    func extractDetections(_ results: [VNObservation]) {
        // Limpar as camadas de detecção existentes
        detectionLayer?.sublayers = nil
        
        // Iterar sobre os resultados da detecção
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
            
            
            // Transformar as coordenadas normalizadas em coordenadas de tela
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(screenRect.size.width), Int(screenRect.size.height))
            let transformedBounds = CGRect(
                x: objectBounds.maxX + 300,
                y: screenRect.size.height - objectBounds.maxY + 100,
                width: objectBounds.maxX - objectBounds.minX,
                height: objectBounds.maxY - objectBounds.minY
            )
            
            
            // Desenhar a caixa delimitadora ao redor do objeto detectado
            let boxLayer = self.drawBoundingBox(transformedBounds)

            // Adicionar a caixa delimitadora à camada de detecção
            detectionLayer?.addSublayer(boxLayer)
        }
    }
    
    
    func setupLayers() {
        // Criar uma nova camada de detecção
        detectionLayer = CALayer()
        detectionLayer?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        // Adicionar a camada de detecção à visualização principal
        DispatchQueue.main.async {
            if let window = NSApplication.shared.mainWindow,
               let contentView = window.contentView,
               let layer = contentView.layer {
                layer.addSublayer(self.detectionLayer)
            }
        }
    }
    
    // Método para atualizar o tamanho da camada de detecção com base na orientação do dispositivo
    func updateLayers() {
        detectionLayer?.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
    }
    
    // Método para desenhar a caixa delimitadora ao redor do objeto detectado
    func drawBoundingBox(_ bounds: CGRect) -> CALayer {
        let boxLayer = CALayer()
        boxLayer.frame = bounds
        boxLayer.borderWidth = 7.0
        boxLayer.borderColor = CGColor.init(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
        boxLayer.cornerRadius = 5
        return boxLayer
    }
    
    // Método chamado quando um novo quadro de vídeo é capturado
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Converter o buffer de amostra em um buffer de pixel
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        // Criar um manipulador de solicitação de imagem para processar o buffer de pixel
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

        do {
            // Executar as solicitações de visão no buffer de imagem
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}

