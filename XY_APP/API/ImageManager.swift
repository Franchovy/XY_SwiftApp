//
//  ImageFile.swift
//  XY_APP
//
//  Created by Maxime Franchot on 03/12/2020.
//

import Foundation
import UIKit



struct UploadImageRequest : Encodable
{
    let attachment : String
    let fileName : String
}

struct getImageRequest : Encodable
{
    let imageref: String
}

struct ImageResponse : Decodable
{
    let imageData: String?
    let message: String
    let id: String
}


struct ImageManager
{
    func uploadImage(image: UIImage, completionHandler: @escaping(_ result: ImageResponse) -> Void)
    {
        let httpUtility = HttpUtility()
        
        let data = image.pngData()
        let imageUploadRequest = UploadImageRequest(attachment: data!.base64EncodedString(), fileName: "file")

        httpUtility.postApiDataWithMultipartForm(requestUrl: URL(string: API_URL + "/upload_image")!, request: imageUploadRequest, resultType: ImageResponse.self) {
            (response) in

            DispatchQueue.main.async {
                _ = completionHandler(response)
            }
        }
    }
    
    func downloadImage(imageID:String, completion: @escaping(_ result: UIImage?) -> Void) {
        let httpUtility = HttpUtility()
        
        var urlRequest = URLRequest(url: URL(string: API_URL + "/get_image")!)
        urlRequest.addValue(imageID, forHTTPHeaderField: "imageID")
        
        httpUtility.getApiData(requestUrl: urlRequest, resultType: ImageResponse.self, completionHandler: { result in
            print("Received photo from request:", result!.message)
            //TODO - Check to result to make sure request has imageData. 
            if let result = result {
                let imageData = result.imageData!
                
                if let base64Decoded = Data(base64Encoded: imageData, options: Data.Base64DecodingOptions(rawValue: 0)) {
                    // Convert back to a string
                    print("Decoded: \(base64Decoded)")
                    let img = UIImage(data: base64Decoded)
                    DispatchQueue.main.async {
                        completion(img)
                    }
                }
            }
        })
    }
}
