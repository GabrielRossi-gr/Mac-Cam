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
                    .frame(width: 500, height: 200)
                CameraView()
                    .frame(width: 500, height: 200)
                CameraView()
                    .frame(width: 500, height: 200)
            }
            
            VStack{
                CameraView()
                    .frame(width: 500, height: 200)
                CameraView()
                    .frame(width: 500, height: 200)
                CameraView()
                    .frame(width: 500, height: 200)
            }
        }
    }
}

#Preview {
    ContentView()
}
