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
    private var uuidMap = [UIImageView: UUID]()
    
    private init() {}
    
    func load(_ url: NSURL, for imageView: UIImageView) {
        
        let token = ImagesCatch.publicCache.load(url: url, completion: { image in
            defer {
                self.uuidMap.removeValue(forKey: imageView)
            }
            DispatchQueue.main.async {
              imageView.image = image
            }
        })

         if let token = token {
           uuidMap[imageView] = token
         }
    }
    
    func cancel(for imageView: UIImageView) {
        if let uuid = uuidMap[imageView] {
            imageLoader.cancelLoad(uuid)
            uuidMap.removeValue(forKey: imageView)
        }
    }
}

extension UIImageView {
    func setImageFrom(url: String) {
        let url = NSURL(string: url) ?? NSURL()
        ImageLoader.shared.load(url, for: self)
    }
    
    func cancelRequest() {
        ImageLoader.shared.cancel(for: self)
    }
}
