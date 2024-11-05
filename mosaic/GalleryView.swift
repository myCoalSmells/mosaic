//
//  GalleryView.swift
//  mosaic
//
//  Created by Liu, Michael on 11/4/24.
//

import SwiftUI
import PhotosUI

struct GalleryView: View {
    @State private var imageURLs: [URL] = []
    @State private var selectedURLs: Set<URL> = []
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @State private var itemsToShare: [Any] = []
    @State private var showingImagePicker = false
    @State private var isImporting = false
    
    var body: some View {
        ScrollView {
            HStack {
                if !imageURLs.isEmpty {
                    Button(action: { isEditing.toggle() }) {
                        Text(isEditing ? "Done" : "Select")
                    }
                }
                
                Spacer()
                
                Button(action: { showingImagePicker = true }) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                }
                .disabled(isImporting)
                
                if isEditing {
                    Button(action: shareSelectedPhotos) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Button(action: saveSelectedToPhotos) {
                        Image(systemName: "square.and.arrow.down")
                    }
                    Button(action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal)
            
            if isImporting {
                ProgressView("Importing photos...")
                    .padding()
            }
            
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
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: itemsToShare)
        }
        .sheet(isPresented: $showingImagePicker) {
            PhotoPicker(completion: handleSelectedImages)
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
    
    private func shareSelectedPhotos() {
        itemsToShare = selectedURLs.compactMap { url in
            UIImage(contentsOfFile: url.path)
        }
        showingShareSheet = true
    }
    
    private func handleSelectedImages(_ images: [UIImage]) {
        guard !images.isEmpty else { return }
        
        isImporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            for image in images {
                let timestamp = Int(Date().timeIntervalSince1970 * 1000) // milliseconds for uniqueness
                let fileName = "photo_\(timestamp).jpg"
                if let url = ImageManager.shared.saveImageLocally(image: image, fileName: fileName) {
                    DispatchQueue.main.async {
                        imageURLs.append(url)
                    }
                }
            }
            
            DispatchQueue.main.async {
                isImporting = false
            }
        }
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

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct PhotoPicker: UIViewControllerRepresentable {
    let completion: ([UIImage]) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0  // 0 means no limit
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            let dispatchGroup = DispatchGroup()
            var images: [UIImage] = []
            
            for result in results {
                dispatchGroup.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    defer { dispatchGroup.leave() }
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.parent.completion(images)
            }
        }
    }
}

#Preview {
    GalleryView()
}

