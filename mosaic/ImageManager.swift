//
//  ImageManager.swift
//  mosaic
//
//  Created by Liu, Michael on 10/14/24.
//


import UIKit

class ImageManager {
    static let shared = ImageManager()
    
    func saveImageToCameraRoll(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

