//
//  Profile.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import Foundation
import UIKit

struct Profile {
    var username:String
    var coverPhoto:UIImage?
    var profilePhoto:UIImage?
    
    init(username : String) {
        self.username = username
    }
    
    // Backend API call to get profile data for this user
    func getProfile(completion: (Result<Bool, Error>)) {
        // create request
        // save request
        // set this profile attributes, coverPhoto & profilePhoto
        // call completionhandler
    }
    
    struct UploadImageRequestMessage:Codable {
        var image:Data?
        
        init(image:Data?) {
            self.image = image
        }
    }
    
    // Upload image for profile or cover picture
    func uploadImageOne(image: UIImage, completion: @escaping(Result<ResponseMessage, APIError>) -> Void) {
        var imageData = image.pngData()

        if imageData != nil{
            let url = API.url + "/upload_image"
            
            // Initialise the Http Request
            var urlRequest = URLRequest(url: URL(string: url)!)
            
            urlRequest.addValue(API.getSessionToken(), forHTTPHeaderField: "Session")
            urlRequest.httpMethod = "POST"

            var boundary = NSString(format: "---------------------------14737809831466499882746641449")
            var contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
            //  pr as Stringintln("Content Type \(contentType)")
            urlRequest.addValue(contentType as String, forHTTPHeaderField: "Content-Type")

            var body = NSMutableData()

            // Add image to body of http request
            body.append("--\(boundary)\r\n" .data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)

            body.append(imageData!)

            body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
            body.append("\r\n--%@\r\n".data(using: .utf8)!)
            
            urlRequest.httpBody = body.base64EncodedData()

            
            // Open the task as urlRequest
            let dataTask = URLSession.shared.dataTask(with: urlRequest) {data, response, _ in
                // Save response or handle Error
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
                    print("Error: response problem with API call to upload_photo: \(response)")
                    completion(.failure(.responseProblem))
                    return
                }
                // Handle result
                do {
                    // Decode the response
                    let messageData = try JSONDecoder().decode(ResponseMessage.self, from: jsonData) // Todo: Change Message struct for response
                    completion(.success(messageData))
                } catch {
                    // Error decoding the message
                    print("Error decoding the response.")
                    print(error)
                    completion(.failure(.decodingProblem))
                }
            }
            dataTask.resume() // Execute the httpRequest task
        }


    }
}
