//
//  Constants.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 8/29/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import Foundation
import UIKit
import Firebase

let screenHeight = UIScreen.main.bounds.height - (UIApplication.shared.keyWindow?.safeAreaInsets.top)! - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!
let REF_USERS = Database.database().reference().child("Users")
let MAX_IMAGE_SIZE_BYTES : Int = 800000
