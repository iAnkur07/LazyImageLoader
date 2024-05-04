//
//  NetworkManager.swift
//  LazyImageLoader
//
//  Created by Ankur on 04/05/24.
//

import UIKit

class NetworkManager: NSObject {
    static let shared = NetworkManager()
    
    private let baseURL = "https://acharyaprashant.org/api/v2/content/misc/media-coverages"
    
    func getImages(lastCount: Int,
                   completion: @escaping(Result<[ImageModel], APIError>) -> Void) {
        
        guard let url = URL(string: baseURL + "?limit=\(lastCount)") else {
            completion(.failure(.noAPiMethod()))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error with fetching data: \(error)")
                completion(.failure(.init(message: error.localizedDescription, code: .unknown)))
                return
            }
            
//            guard let httpResponse = response as? HTTPURLResponse,
//                  (200...299).contains(httpResponse.statusCode) else {
//                print("Error with the response, unexpected status code: \(response)")
//                return
//            }
            
            if let data = data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]]
                    completion(.success(self.toImageModel(jsonObject ?? [])))
                } catch {
                    print("Error with fetching data: \(error)")
                    completion(.failure(.init(message: error.localizedDescription, code: .unknown)))
                }
                
            } else {
                completion(.failure(.init(message: "Data not found", code: .unknown)))
            }
            
           
            
        }
        
        task.resume()
    }
}

// MARK: - Data converter
extension NetworkManager {
    private func toImageModel(_ response: [[String: Any]]) -> [ImageModel] {
        var result = [ImageModel]()
        
        for item in response {
            let thumbnail = item["thumbnail"] as? [String: Any]
            
            let id = thumbnail?["id"] as? String ?? ""
            let domain = thumbnail?["domain"] as? String ?? ""
            let basePath = thumbnail?["basePath"] as? String ?? ""
            let key = thumbnail?["key"] as? String ?? ""
            let url = domain + "/" + basePath + "/0/" + key
            result.append(ImageModel(id: id, url: url))
        }
        
        return result
    }
}

// MARK: - APIError - Hanlder
struct APIError: Error {
    // error title from API response
    var title: String?
    // error message from API response
    var message = ""
    // error code from API response
    var code: Code = .unknown

    enum Code: Int {
        case noInternet = -1
        case unknown = 0
        case accessDenied = 1
        case invalidSessionKey = 2
        case unauthorized = 3
    }

    // error message to display
    var messageToDisplay: String {
        return message.isEmpty ? "Unknown error. Please try again." : message
    }

    init() {
        // empty init
    }

    init(message: String?, code: Code) {
        self.message = message ?? ""
        self.code = code
    }

    // client side errors
    static func unknown() -> APIError {
        return APIError(
                message: "Something went wrong. Please check your internet connection and try again.",
                code: .unknown
        )
    }
    
    static func noAPiMethod() -> APIError {
        return APIError(
                message: "No API Method Yet",
                code: .unknown
        )
    }

    static func noInternet() -> APIError {
        return APIError(
                message: "Something went wrong. Please check your internet connection and try again.",
                code: .noInternet
        )
    }
}
