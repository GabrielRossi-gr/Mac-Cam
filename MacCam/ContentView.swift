//
//  ContentView.swift
//  MacCam
//
//  Created by Gabriel Rossi on 26/03/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
            
            
            CameraView()
                .frame(width: 400, height: 400)
                .cornerRadius(30)
            
            CameraView()
                .frame(width: 400, height: 400)
                .cornerRadius(30)
            
            CameraView()
                .frame(width: 400, height: 400)
                .cornerRadius(30)
            
        }
    }
}

#Preview {
    ContentView()
}
