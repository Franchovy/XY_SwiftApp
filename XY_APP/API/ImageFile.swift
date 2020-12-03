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

struct ImageResponse : Decodable
{
    let path: String
}

// Hey there, I hope the video helped you, and if it did do like the video and share it with your iOS group. Do let me know if you have any questions on this topic and I will be happy to help you out :) ~ Ravi
struct ImageManager
{
    func uploadImage(data: Data, completionHandler: @escaping(_ result: ImageResponse) -> Void)
    {
        let httpUtility = HttpUtility()

        let imageUploadRequest = ImageRequest(attachment: data.base64EncodedString(), fileName: "multipartFormUploadExample")

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
}
