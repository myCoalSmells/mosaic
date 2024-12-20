//
//  NetworkManager.swift
//  mosaic
//
//  Created by Liu, Michael on 10/14/24.
//

import Foundation
import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    
    let piIPAddress = "http:localhost:5001" // replace with pi ip address
    
    func capturePhoto(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(piIPAddress)/capture") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error capturing photo: \(error)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Unexpected response")
                completion(false)
                return
            }
            
            completion(true)
        }
        task.resume()
    }
    
    func fetchImage(saveToPhotos: Bool = false, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: "\(piIPAddress)/image") else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching image: \(error)")
                completion(nil)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                // Save to Camera Roll if option selected
                if saveToPhotos {
                    ImageManager.shared.saveImageToCameraRoll(image: image)
                }
                
                // Save to local storage with a timestamped filename
                let timestamp = Int(Date().timeIntervalSince1970)
                let fileName = "photo_\(timestamp).jpg"
                ImageManager.shared.saveImageLocally(image: image, fileName: fileName)
                
                completion(image)
            } else {
                print("Failed to decode image data")
                completion(nil)
            }
        }
        task.resume()
    }
}

