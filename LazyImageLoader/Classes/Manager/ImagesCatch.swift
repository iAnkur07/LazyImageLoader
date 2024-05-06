//
//  ImagesCatch.swift
//  LazyImageLoader
//
//  Created by Ankur on 04/05/24.
//

import UIKit

class ImagesCatch: NSObject {
    
    static let publicCache = ImagesCatch()
    var placeholderImage = UIImage(systemName: "rectangle")!
    
    private let cachedImages = NSCache<NSURL, UIImage>()
    private var runningRequests = [UUID: URLSessionDataTask]()
    private var uuidMap = [UIImageView: UUID]()
    private var loadingResponses = [NSURL: [(UIImage?) -> Void]]()
    
    final func image(url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    
    func load(url: NSURL, completion: @escaping (UIImage?) -> Swift.Void) -> UUID? {
        // Check for a cached image.
        if let cachedImage = image(url: url) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return nil
        }

        if loadingResponses[url] != nil {
            loadingResponses[url]?.append(completion)
            return nil
        } else {
            loadingResponses[url] = [completion]
        }
        
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url as URL) { (data, reponse, error) in
            
            defer {
                self.runningRequests.removeValue(forKey: uuid)
            }
            
            guard let responseData = data, let image = UIImage(data: responseData),
                  let blocks = self.loadingResponses[url], error == nil else {
                DispatchQueue.main.async {
                    print("\(url) -> Faild to load \(error?.localizedDescription ?? "")")
                    completion(nil)
                }
                return
            }
            self.cachedImages.setObject(image, forKey: url, cost: responseData.count)
            for block in blocks {
                DispatchQueue.main.async {
                    block(image)
                }
                return
            }
        }
        task.resume()
        
        runningRequests[uuid] = task
        return uuid
    }
    
    func cancelLoad(_ uuid: UUID) {
        print("removed tasks: \(uuid.uuidString)")
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}
