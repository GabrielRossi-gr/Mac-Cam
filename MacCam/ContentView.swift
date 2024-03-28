//
//  ContentView.swift
//  MacCam
//
//  Created by Gabriel Rossi on 26/03/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack{
            HostedViewController()
//            CameraView()
        }
    }
}

#Preview {
    ContentView()
}


// Estrutura para encapsular NSViewController em SwiftUI
struct HostedViewController: NSViewControllerRepresentable {

    // Método para criar o NSViewController
    func makeNSViewController(context: Context) -> NSViewController {
        return ViewController()
    }

    // Método para atualizar o NSViewController (não é usado neste exemplo)
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {
    }
}
