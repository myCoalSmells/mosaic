//
//  ImageManager.swift
//  mosaic
//
//  Created by Liu, Michael on 10/14/24.
//

import UIKit

class ImageManager {
    static let shared = ImageManager()
    
    // Directory for local image storage
    private var imageDirectoryURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("CapturedImages")
    }
    
    init() {
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: imageDirectoryURL.path) {
            try? FileManager.default.createDirectory(at: imageDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    // Save image locally
    func saveImageLocally(image: UIImage, fileName: String) -> URL? {
        let fileURL = imageDirectoryURL.appendingPathComponent(fileName)
        print("Saving image to \(fileURL)")
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: fileURL)
                print("Image saved successfully at \(fileURL)")
                return fileURL
            } catch {
                print("Error saving image locally: \(error)")
            }
        } else {
            print("Failed to generate JPEG data for image.")
        }
        return nil
    }
    
    // Load all saved images
    func loadSavedImages() -> [UIImage] {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: imageDirectoryURL, includingPropertiesForKeys: nil)
            return fileURLs.compactMap { UIImage(contentsOfFile: $0.path) }
        } catch {
            print("Error loading saved images: \(error)")
            return []
        }
    }
    
    // Save image to camera roll
    func saveImageToCameraRoll(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func loadSavedImageURLs() -> [URL] {
        do {
            return try FileManager.default.contentsOfDirectory(at: imageDirectoryURL, includingPropertiesForKeys: nil)
        } catch {
            print("Error loading saved image URLs: \(error)")
            return []
        }
    }
}

