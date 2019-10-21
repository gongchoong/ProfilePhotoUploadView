

import UIKit

class User: NSObject {
    var name: String?
    var imageUrls: [String: String]?
    var id: String?
    
    init(_ dictionary: [String: AnyObject]){
        super.init()
        name = dictionary["name"] as? String
        imageUrls = dictionary["imageUrls"] as? [String: String]
    }
    
    func getProfileImageUrl() -> String?{
        if let images = imageUrls{
            return images["url1"]
        }else{
            return nil
        }
    }
    
}

