//
//  GalleryView.swift
//  mosaic
//
//  Created by Liu, Michael on 11/4/24.
//

import SwiftUI

struct GalleryView: View {
    @State private var imageURLs: [URL] = []
    @State private var selectedURLs: Set<URL> = []
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            HStack {
                if !imageURLs.isEmpty {
                    Button(action: { isEditing.toggle() }) {
                        Text(isEditing ? "Done" : "Select")
                    }
                    
                    if isEditing {
                        Spacer()
                        Button(action: saveSelectedToPhotos) {
                            Image(systemName: "square.and.arrow.down")
                        }
                        Button(action: { showingDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                ForEach(imageURLs, id: \.self) { url in
                    if FileManager.default.fileExists(atPath: url.path),
                       let image = UIImage(contentsOfFile: url.path) {
                        if isEditing {
                            SelectableImageView(image: image, isSelected: selectedURLs.contains(url)) {
                                if selectedURLs.contains(url) {
                                    selectedURLs.remove(url)
                                } else {
                                    selectedURLs.insert(url)
                                }
                            }
                        } else {
                            NavigationLink(destination: ImageDetailView(image: image, imageURL: url, onDelete: loadImages)) {
                                ImageThumbnailView(image: image)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Gallery")
        .onAppear(perform: loadImages)
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Selected Photos"),
                message: Text("Are you sure you want to delete \(selectedURLs.count) selected photos? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteSelectedPhotos()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func loadImages() {
        imageURLs = ImageManager.shared.loadSavedImageURLs()
        selectedURLs.removeAll()
        isEditing = false
    }
    
    private func saveSelectedToPhotos() {
        for url in selectedURLs {
            if let image = UIImage(contentsOfFile: url.path) {
                ImageManager.shared.saveImageToCameraRoll(image: image)
            }
        }
        isEditing = false
        selectedURLs.removeAll()
    }
    
    private func deleteSelectedPhotos() {
        for url in selectedURLs {
            try? FileManager.default.removeItem(at: url)
        }
        loadImages()
    }
}

struct SelectableImageView: View {
    let image: UIImage
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                ImageThumbnailView(image: image)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .background(Circle().fill(.white))
                    .padding(4)
            }
        }
    }
}

struct ImageThumbnailView: View {
    let image: UIImage
    
    var body: some View {
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

#Preview {
    GalleryView()
}

