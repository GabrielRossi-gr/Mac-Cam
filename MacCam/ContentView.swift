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
            
            VStack{
                CameraView()
                    .frame(width: 600, height: 300)
                CameraView()
                    .frame(width: 600, height: 300)
                CameraView()
                    .frame(width: 600, height: 300)
            }
            
            VStack{
                CameraView()
                    .frame(width: 600, height: 300)
                CameraView()
                    .frame(width: 600, height: 300)
                CameraView()
                    .frame(width: 600, height: 300)
            }
        }
    }
}

#Preview {
    ContentView()
}
