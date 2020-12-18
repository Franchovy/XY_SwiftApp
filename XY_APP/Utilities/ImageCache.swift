//
//  PictureLoader.swift
//  XY_APP
//
//  Created by Maxime Franchot on 14/12/2020.
//

import Foundation
import UIKit

// Async class used by FlowTableView to store, and fetch images using async calls
class ImageCache {
    
    // MARK: - ENUMS
    
    enum ImageCacheError:Error {
        case noSuchImage
        case connectionProblem
    }
    
    enum ImageInsertToCacheError:Error {
        case connectionProblem
        case otherProblem
    }
    
    // MARK: - DATA
    
    fileprivate static var cellImageDictionary = [String: UIImage]()
    
    // MARK: - PUBLIC METHODS
    
    static func getOrFetch(id:String, closure: @escaping(Result<UIImage,ImageCacheError>) -> Void) {
        if cellImageDictionary[id] != nil {
            closure(.success(cellImageDictionary[id]!))
            // TODO - ADD FAILURE CASE FOR FETCHING DATA FROM COREDATA
        } else {
            // Fetch if image not present
            downloadImage(imageID: id, completion: { result in
                switch result {
                case .success(let response):
                    print("Request: \(id)")
                    // Insert fetched image into dictionary
                    self.cellImageDictionary[id] = response.image
                    closure(.success(response.image))
                case .failure(let error):
                    closure(.failure(error))
                }
            })
        }
    }
    
    static func insert(id:String, image: UIImage) {
        cellImageDictionary[id] = image
    }
    
    static func insertAndUpload(image: UIImage, closure: @escaping(Result<String, ImageInsertToCacheError>) -> Void) {
        uploadImage(image:image, closure: { result in
            switch result {
            case .success(let imageId):
                closure(.success(imageId))
            case .failure(let error):
                print("Error uploading image: \(error)")
                closure(.failure(error))
            }
        })
    }
    
    
    static func get(id:String) -> UIImage? {
        return cellImageDictionary[id]
    }
    
    // MARK: - API MODELS
    
    // make fileprivate once HttpUtility has been updated
    struct UploadImageRequest : Encodable
    {
        let attachment : String
        let fileName : String
    }

    fileprivate struct ImageUploadResponse : Decodable
    {
        let message: String
        let id: String
    }

    fileprivate struct GetImageRequest : Encodable
    {
        let imageref: String
    }

    fileprivate struct GetImageResponse : Decodable
    {
        let imageData: String?
        let message: String
        let id: String
    }

    // MARK: - API CALLS
    
    static fileprivate func uploadImage(image: UIImage, closure: @escaping(Result<String, ImageInsertToCacheError>) -> Void)
    {
        let httpUtility = HttpUtility()
        
        let data = image.pngData()
        let imageUploadRequest = UploadImageRequest(attachment: data!.base64EncodedString(), fileName: "file")

        httpUtility.postApiDataWithMultipartForm(requestUrl: URL(string: API_URL + "/upload_image")!, request: imageUploadRequest, resultType: ImageUploadResponse.self) { result in
            if result != nil {
                if result.id != "" {
                    DispatchQueue.main.async {
                        closure(.success(result.id))
                    }
                } else if result.message != "" {
                    print("Error uploading image: \(result.message)")
                    closure(.failure(.otherProblem))
                }
            } else {
                closure(.failure(.connectionProblem))
            }
        }
    }
        
    static fileprivate func downloadImage(imageID:String, completion: @escaping(Result<(image:UIImage,id:String),ImageCacheError>) -> Void) {
        let httpUtility = HttpUtility()
        
        var urlRequest = URLRequest(url: URL(string: API_URL + "/get_image")!)
        urlRequest.addValue(imageID, forHTTPHeaderField: "imageID")
        
        httpUtility.getApiData(requestUrl: urlRequest, resultType: GetImageResponse.self, completionHandler: { result in
            
            if let imageData = result?.imageData, let id = result?.id {
                
                if let base64Decoded = Data(base64Encoded: imageData, options: Data.Base64DecodingOptions(rawValue: 0)) {
                    // Convert back to a string
                    let img = UIImage(data: base64Decoded)!
                    // Completion Handler
                    DispatchQueue.main.async {
                        completion(.success((image:img, id:id)))
                    }
                }
            } else if let message = result?.message {
                print("Response Error getting image from backend: \(message)")
                completion(.failure(.noSuchImage))
            } else {
                completion(.failure(.connectionProblem))
            }
        })
    }

}
