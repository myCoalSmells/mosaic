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
    
    var body: some View {
        VStack {
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
        }
        .padding()
        .navigationTitle("Image Details")
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

#Preview {
    ImageDetailView(image: UIImage(named: "sampleImage")!, imageURL: URL(fileURLWithPath: "/path/to/sampleImage.jpg"))
}

