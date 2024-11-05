//
//  GalleryView.swift
//  mosaic
//
//  Created by Liu, Michael on 11/4/24.
//

import SwiftUI

struct GalleryView: View {
    @State private var imageURLs: [URL] = []
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                ForEach(imageURLs, id: \.self) { url in
                    if FileManager.default.fileExists(atPath: url.path),
                       let image = UIImage(contentsOfFile: url.path) {
                        NavigationLink(destination: ImageDetailView(image: image, imageURL: url, onDelete: loadImages)) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Gallery")
        .onAppear(perform: loadImages)
    }
    
    private func loadImages() {
        imageURLs = ImageManager.shared.loadSavedImageURLs()
    }
}

#Preview {
    GalleryView()
}

