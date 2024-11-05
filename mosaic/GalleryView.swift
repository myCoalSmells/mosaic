//
//  GalleryView.swift
//  mosaic
//
//  Created by Liu, Michael on 11/4/24.
//

import SwiftUI

struct GalleryView: View {
    private var imageURLs: [URL] = ImageManager.shared.loadSavedImageURLs()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                ForEach(imageURLs, id: \.self) { url in
                    if let image = UIImage(contentsOfFile: url.path) {
                        NavigationLink(destination: ImageDetailView(image: image, imageURL: url)) {
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
    }
}

#Preview {
    GalleryView()
}

