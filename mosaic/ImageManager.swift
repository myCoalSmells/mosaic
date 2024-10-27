//
//  ImageManager.swift
//  mosaic
//
//  Created by Liu, Michael on 10/14/24.
//

// we need permissions for this
import UIKit

class ImageManager {
    static let shared = ImageManager()
    
    func saveImageToCameraRoll(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

