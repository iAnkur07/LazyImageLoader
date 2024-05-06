//
//  Extension.swift
//  LazyImageLoader
//
//  Created by Ankur on 04/05/24.
//

import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    
    private let imageLoader = ImagesCatch()
    private var uuidMap = [Int: UUID]()
    
    private init() {}
    
    func load(_ url: NSURL, index: Int, completion: @escaping (UIImage?, Int) -> Void) {
        
        let token = ImagesCatch.publicCache.load(url: url, completion: { image in
            defer {
                self.uuidMap.removeValue(forKey: index)
            }
            DispatchQueue.main.async {
                completion(image, index)
            }
        })

         if let token = token {
           uuidMap[index] = token
         }
    }
    
    func cancel(for index: Int) {
        if let uuid = uuidMap[index] {
            imageLoader.cancelLoad(uuid)
            
            uuidMap.removeValue(forKey: index)
        }
    }
}

extension UIImageView {
    func setImageFrom(url: String, index: Int, completion: @escaping (UIImage?, Int) -> Void) {
        let url = NSURL(string: url) ?? NSURL()
        ImageLoader.shared.load(url, index: index, completion: completion)
    }
    
    func cancelRequest(index: Int) {
        ImageLoader.shared.cancel(for: index)
    }
}
