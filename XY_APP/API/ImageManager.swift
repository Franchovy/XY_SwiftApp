//
//  ImageFile.swift
//  XY_APP
//
//  Created by Maxime Franchot on 03/12/2020.
//

import Foundation
import UIKit



struct ImageRequest : Encodable
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

// Hey there, I hope the video helped you, and if it did do like the video and share it with your iOS group. Do let me know if you have any questions on this topic and I will be happy to help you out :) ~ Ravi
struct ImageManager
{
    func uploadImage(image: UIImage, completionHandler: @escaping(_ result: ImageResponse) -> Void)
    {
        let httpUtility = HttpUtility()
        
        let data = image.pngData()
        let imageUploadRequest = ImageRequest(attachment: data!.base64EncodedString(), fileName: "file")

        httpUtility.postApiDataWithMultipartForm(requestUrl: URL(string: API.url + "/upload_image")!, request: imageUploadRequest, resultType: ImageResponse.self) {
            (response) in

            _ = completionHandler(response)

        }

        // Upload image with base64 format
        // let imageUploadRequest = ImageRequest(attachment: data.base64EncodedString(), fileName: "base64Example")
        //        do {
        //             let postBody = try JSONEncoder().encode(request)
        //
        //            httpUtility.postApiData(requestUrl: URL(string: Endpoints.uploadImage)!, requestBody: postBody, resultType: ImageResponse.self) { (response) in
        //
        //                _ = completionHandler(response)
        //            }
        //
        //        } catch let error {
        //            debugPrint(error)
        //        }
//----------------------------------------------------------------------------------
        
        // Upload image with byte array format
        // let imageUploadRequest = ImageRequest(attachment: data, fileName: "base64Example")
        //        do {
        //             let postBody = try JSONEncoder().encode(request)
        //
        //            httpUtility.postApiData(requestUrl: URL(string: Endpoints.uploadImageWithByteArray)!, requestBody: postBody, resultType: ImageResponse.self) { (response) in
        //
        //                _ = completionHandler(response)
        //            }
        //
        //        } catch let error {
        //            debugPrint(error)
        //        }

    }
    
    func downloadImage(imageID:String, completion: @escaping(_ result: UIImage?) -> Void) {
        let httpUtility = HttpUtility()
        
        var urlRequest = URLRequest(url: URL(string: API.url + "/get_image")!)
        urlRequest.addValue(imageID, forHTTPHeaderField: "imageID")
        
        httpUtility.getApiData(requestUrl: urlRequest, resultType: ImageResponse.self, completionHandler: { result in
            print("Received photo from request:", result)
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
