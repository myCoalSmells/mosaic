//
//  ContentView.swift
//  mosaic
//
//  Created by Liu, Michael on 10/14/24.
//

import SwiftUI

struct ContentView: View {
    @State private var capturedImage: UIImage? = nil
    @State private var isLoading = false

    var body: some View {
        VStack {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Text("Press capture to take a stereoscopic photo!")
                    .font(.headline)
                    .padding()
            }
            
            Button(action: capturePhoto) {
                Text("Capture Photo")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(isLoading)
            
            if isLoading {
                ProgressView()
                    .padding()
            }
        }
        .padding()
    }
    
    private func capturePhoto() {
        isLoading = true
        NetworkManager.shared.capturePhoto { success in
            if success {
                NetworkManager.shared.fetchImage { image in
                    DispatchQueue.main.async {
                        self.capturedImage = image
                        isLoading = false
                    }
                }
            } else {
                isLoading = false
                print("Failed to capture photo")
            }
        }
    }
}

#Preview {
    ContentView()
}


