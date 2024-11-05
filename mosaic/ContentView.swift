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
    @State private var saveOption = SaveOption.appOnly
    private let hapticFeedback = UINotificationFeedbackGenerator()
    
    enum SaveOption: String, CaseIterable {
        case appOnly = "Save in App"
        case both = "Save in App + Photos Library"
    }
    
    var body: some View {
        NavigationView {
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Save Location:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Picker("", selection: $saveOption) {
                        ForEach(SaveOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
                
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
                
                NavigationLink(destination: GalleryView()) {
                    Text("View Gallery")
                        .font(.title2)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding()
            .navigationTitle("Mosaic")
        }
    }
    
    private func capturePhoto() {
        isLoading = true
        hapticFeedback.prepare()
        
        NetworkManager.shared.capturePhoto { success in
            if success {
                NetworkManager.shared.fetchImage(saveToPhotos: saveOption == .both) { image in
                    DispatchQueue.main.async {
                        self.capturedImage = image
                        self.isLoading = false
                        if image != nil {
                            self.hapticFeedback.notificationOccurred(.success)
                        } else {
                            self.hapticFeedback.notificationOccurred(.error)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.hapticFeedback.notificationOccurred(.error)
                }
                print("Failed to capture photo")
            }
        }
    }
}

#Preview {
    ContentView()
}




