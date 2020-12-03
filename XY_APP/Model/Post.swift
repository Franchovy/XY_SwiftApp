import UIKit


struct PostModel {
    var username:String
    var content:String
    
    // Get XP gained from the post since last time this was used.
    func getXP() -> Int {
        return 0
    }
    
    // Function to fetch from API to get all recent posts.
    static func getAllPosts() -> [PostModel]? {
        // Make API request to backend to signup.
        let getAllPostsRequest = APIRequest(endpoint: "get_all_posts", httpMethod: "GET")
                
        let message = GetAllPostsRequestMessage(token: API.getSessionToken())
        
        getAllPostsRequest.save(message: message, completion: { result in
            switch result {
            case .success(let message):
                print("POST request response: \"\(message.status)\"")
                print("Message data: \(message.response ?? "no data")")
            case .failure(let error):
                print("An error occured: \(error)")
         }
        })
    
        return [PostModel(username: "Elon Musk", content: "Finally, I have joined XY!"), PostModel(username: "XY_AI", content: "You are connected to the backend.")]
    }
}

