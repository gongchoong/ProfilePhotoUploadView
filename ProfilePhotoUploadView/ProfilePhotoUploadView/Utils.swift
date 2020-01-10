//
//  Utils.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 1/9/20.
//  Copyright © 2020 chris davis. All rights reserved.
//

import Foundation
import UIKit

func showErrorMessage(_ viewController: UIViewController, _ message: String, _ completion: @escaping()->()){
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
    alertController.addAction(okAction)
    viewController.present(alertController, animated: true) {
        completion()
    }
}
