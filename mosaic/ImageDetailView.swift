//
//  ImageDetailView.swift
//  mosaic
//
//  Created by Liu, Michael on 11/4/24.
//

import SwiftUI

struct ImageDetailView: View {
    let image: UIImage
    let imageURL: URL
    let onDelete: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    @State private var is3DMode = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            if is3DMode {
                StereoView(image: image)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Button(action: { is3DMode = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(),
                        alignment: .topLeading
                    )
            } else {
                VStack {
                    // Existing detail view content
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .padding()
                    
                    Text("File Name: \(imageURL.lastPathComponent)")
                        .font(.subheadline)
                        .padding(.top)
                    
                    if let creationDate = getFileCreationDate(for: imageURL) {
                        Text("Captured on: \(creationDate)")
                            .font(.subheadline)
                            .padding(.top, 1)
                    }
                    
                    Spacer()
                    
                    Button(action: { is3DMode = true }) {
                        Label("View in 3D", systemImage: "view.3d")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        Button(action: saveToPhotos) {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { showingDeleteAlert = true }) {
                            Label("Delete", systemImage: "trash")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom)
                }
                .padding()
            }
        }
        .navigationBarHidden(is3DMode)
        .navigationTitle(is3DMode ? "" : "Image Details")
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Photo"),
                message: Text("Are you sure you want to delete this photo? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deletePhoto()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func saveToPhotos() {
        ImageManager.shared.saveImageToCameraRoll(image: image)
    }
    
    private func deletePhoto() {
        do {
            try FileManager.default.removeItem(at: imageURL)
            onDelete()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error deleting photo: \(error)")
        }
    }
    
    // Helper function to get file creation date
    private func getFileCreationDate(for url: URL) -> String? {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        if let creationDate = attributes?[.creationDate] as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: creationDate)
        }
        return nil
    }
}

struct StereoView: View {
    let image: UIImage
    @State private var showControls = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .rotationEffect(.degrees(90))
                    .frame(width: geometry.size.height, height: geometry.size.width)
                    .background(Color.black)
                    .onTapGesture {
                        withAnimation {
                            showControls.toggle()
                        }
                    }
                
                if showControls {
                    VStack {
                        HStack {
                            Button(action: { showControls = false }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .statusBar(hidden: true)
    }
}

#Preview {
    ImageDetailView(image: UIImage(named: "sampleImage")!, imageURL: URL(fileURLWithPath: "/path/to/sampleImage.jpg"), onDelete: {})
}

