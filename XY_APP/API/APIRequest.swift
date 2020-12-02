//
//  APIRequest.swift
//  XY_APP
//
//  Created by Maxime Franchot on 24/11/2020.
//

import Foundation


struct API {

    // GLOBAL API VAR - SET THIS TO CONNECT TO BACKEND
    static let url = "http://192.168.1.9:5000"

    // Session token coming from server
    static var sessionToken: String = ""

    // Static function for setting the session token
    static func setSessionToken(newSessionToken: String) {
        API.sessionToken = newSessionToken
    }
    
    // Static function for getting the session token
    static func getSessionToken() -> String {
        return API.sessionToken
    }
}


enum APIError:Error {
    case responseProblem
    case encodingProblem
    case decodingProblem
    case otherProblem
}

struct APIRequest {
    let resourceURL: URL
    let httpMethod: String
    
    
    init(endpoint: String, httpMethod: String) {
        let resourceString = API.url + "/" + endpoint
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        
        switch httpMethod {
        case "POST": self.httpMethod = httpMethod
        case "GET": self.httpMethod = httpMethod
        case "PUT": self.httpMethod = httpMethod
        default:
            print("ERROR: The given httpMethod is unavailable: \(httpMethod)")
            fatalError()
        }
        
        self.resourceURL = resourceURL
    }
    
    
    // JSON HANDLING TESTS
    struct ResponseStruct: Codable {
            let posts: [Post]?
            let mimetype: String?
            let status: Int
            let message:String?
            let data:String?
            let token:String?
       }

       // MARK: - Product
       struct Post: Codable {
           let username, content: String
           let images: [String]
           
           enum CodingKeys: String, CodingKey {
               case username = "username"
               case content = "content"
               case images
           }
       }
        class JSONNull: Codable, Hashable {

            public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
                return true
            }

            public var hashValue: Int {
                return 0
            }

            public init() {}

            public required init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
                }
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encodeNil()
            }
        }

        class JSONCodingKey: CodingKey {
            let key: String

            required init?(intValue: Int) {
                return nil
            }

            required init?(stringValue: String) {
                key = stringValue
            }

            var intValue: Int? {
                return nil
            }

            var stringValue: String {
                return key
            }
        }

        class JSONAny: Codable {

            let value: Any

            static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
                return DecodingError.typeMismatch(JSONAny.self, context)
            }

            static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
                let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
                return EncodingError.invalidValue(value, context)
            }

            static func decode(from container: SingleValueDecodingContainer) throws -> Any {
                if let value = try? container.decode(Bool.self) {
                    return value
                }
                if let value = try? container.decode(Int64.self) {
                    return value
                }
                if let value = try? container.decode(Double.self) {
                    return value
                }
                if let value = try? container.decode(String.self) {
                    return value
                }
                if container.decodeNil() {
                    return JSONNull()
                }
                throw decodingError(forCodingPath: container.codingPath)
            }

            static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
                if let value = try? container.decode(Bool.self) {
                    return value
                }
                if let value = try? container.decode(Int64.self) {
                    return value
                }
                if let value = try? container.decode(Double.self) {
                    return value
                }
                if let value = try? container.decode(String.self) {
                    return value
                }
                if let value = try? container.decodeNil() {
                    if value {
                        return JSONNull()
                    }
                }
                if var container = try? container.nestedUnkeyedContainer() {
                    return try decodeArray(from: &container)
                }
                if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
                    return try decodeDictionary(from: &container)
                }
                throw decodingError(forCodingPath: container.codingPath)
            }

            static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
                if let value = try? container.decode(Bool.self, forKey: key) {
                    return value
                }
                if let value = try? container.decode(Int64.self, forKey: key) {
                    return value
                }
                if let value = try? container.decode(Double.self, forKey: key) {
                    return value
                }
                if let value = try? container.decode(String.self, forKey: key) {
                    return value
                }
                if let value = try? container.decodeNil(forKey: key) {
                    if value {
                        return JSONNull()
                    }
                }
                if var container = try? container.nestedUnkeyedContainer(forKey: key) {
                    return try decodeArray(from: &container)
                }
                if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
                    return try decodeDictionary(from: &container)
                }
                throw decodingError(forCodingPath: container.codingPath)
            }

            static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
                var arr: [Any] = []
                while !container.isAtEnd {
                    let value = try decode(from: &container)
                    arr.append(value)
                }
                return arr
            }

            static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
                var dict = [String: Any]()
                for key in container.allKeys {
                    let value = try decode(from: &container, forKey: key)
                    dict[key.stringValue] = value
                }
                return dict
            }

            static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
                for value in array {
                    if let value = value as? Bool {
                        try container.encode(value)
                    } else if let value = value as? Int64 {
                        try container.encode(value)
                    } else if let value = value as? Double {
                        try container.encode(value)
                    } else if let value = value as? String {
                        try container.encode(value)
                    } else if value is JSONNull {
                        try container.encodeNil()
                    } else if let value = value as? [Any] {
                        var container = container.nestedUnkeyedContainer()
                        try encode(to: &container, array: value)
                    } else if let value = value as? [String: Any] {
                        var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                        try encode(to: &container, dictionary: value)
                    } else {
                        throw encodingError(forValue: value, codingPath: container.codingPath)
                    }
                }
            }

            static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
                for (key, value) in dictionary {
                    let key = JSONCodingKey(stringValue: key)!
                    if let value = value as? Bool {
                        try container.encode(value, forKey: key)
                    } else if let value = value as? Int64 {
                        try container.encode(value, forKey: key)
                    } else if let value = value as? Double {
                        try container.encode(value, forKey: key)
                    } else if let value = value as? String {
                        try container.encode(value, forKey: key)
                    } else if value is JSONNull {
                        try container.encodeNil(forKey: key)
                    } else if let value = value as? [Any] {
                        var container = container.nestedUnkeyedContainer(forKey: key)
                        try encode(to: &container, array: value)
                    } else if let value = value as? [String: Any] {
                        var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                        try encode(to: &container, dictionary: value)
                    } else {
                        throw encodingError(forValue: value, codingPath: container.codingPath)
                    }
                }
            }

            static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
                if let value = value as? Bool {
                    try container.encode(value)
                } else if let value = value as? Int64 {
                    try container.encode(value)
                } else if let value = value as? Double {
                    try container.encode(value)
                } else if let value = value as? String {
                    try container.encode(value)
                } else if value is JSONNull {
                    try container.encodeNil()
                } else {
                    throw encodingError(forValue: value, codingPath: container.codingPath)
                }
            }

            public required init(from decoder: Decoder) throws {
                if var arrayContainer = try? decoder.unkeyedContainer() {
                    self.value = try JSONAny.decodeArray(from: &arrayContainer)
                } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
                    self.value = try JSONAny.decodeDictionary(from: &container)
                } else {
                    let container = try decoder.singleValueContainer()
                    self.value = try JSONAny.decode(from: container)
                }
            }

            public func encode(to encoder: Encoder) throws {
                if let arr = self.value as? [Any] {
                    var container = encoder.unkeyedContainer()
                    try JSONAny.encode(to: &container, array: arr)
                } else if let dict = self.value as? [String: Any] {
                    var container = encoder.container(keyedBy: JSONCodingKey.self)
                    try JSONAny.encode(to: &container, dictionary: dict)
                } else {
                    var container = encoder.singleValueContainer()
                    try JSONAny.encode(to: &container, value: self.value)
                }
            }
        }
    
    
    func save<T: Codable> (message:T, completion: @escaping(Result<ResponseMessage, APIError>) -> Void) {

        
        do {
            // Initialise the Http Request
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = self.httpMethod
            urlRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")
            // Encode the codableMessage properties into JSON for Http Request
            if urlRequest.httpMethod != "GET" {
                urlRequest.httpBody = try JSONEncoder().encode(message)
                print("Sending request: \(message)") // decode struct
            }
            urlRequest.addValue(API.getSessionToken(), forHTTPHeaderField: "Session")
            
            
            // Open the task as urlRequest
            let dataTask = URLSession.shared.dataTask(with: urlRequest) {data, response, _ in
                // Save response or handle Error
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
                    print("Error: response problem with API call to \(resourceURL): \(response)")
                    completion(.failure(.responseProblem))
                    return
                }
                // Handle result
                do {
                    // Decode the response
                    let messageData = try JSONDecoder().decode(ResponseMessage.self, from: jsonData) // Todo: Change Message struct for response
                    if let responseData = messageData.response {
                        let welcome = try JSONDecoder().decode(ResponseStruct.self, from: jsonData)
                        let products = welcome.posts
                        if let post = products?[0] {
                            print(post.username)
                        }
                        
                        for post in responseData {
                            print("New post:")
                            print(post)
                        }
                            
                    }
                    
                    completion(.success(messageData))
                } catch {
                    // Error decoding the message
                    completion(.failure(.decodingProblem))
                }
            }
            dataTask.resume() // Execute the httpRequest task
        } catch {
            // Error encoding the message struct
            completion(.failure(.encodingProblem))
        }
    }

}

