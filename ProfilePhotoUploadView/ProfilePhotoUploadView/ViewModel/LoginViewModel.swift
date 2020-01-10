//
//  LoginViewModel.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 1/9/20.
//  Copyright © 2020 chris davis. All rights reserved.
//

import UIKit
import Firebase

protocol LoginViewModelDelegate: class {
    func showErrorMessage(_ errorMessage: String)
    func dismissLoginViewController()
}

class LoginViewModel: NSObject {
    
    weak var loginViewController: LoginViewController?
    var emailTextField: UITextField?
    var passwordTextField: UITextField?
    var loginButton: UIButton?
    
    var delegate: LoginViewModelDelegate?
    
    init(_ viewController: LoginViewController) {
        super.init()
        loginViewController = viewController
        
        if let vc = loginViewController{
            emailTextField = vc.emailTextField
            passwordTextField = vc.passwordTextField
            loginButton = vc.loginButton
        }
    
    }
    
    func handleLogin(){
        if let email = emailTextField?.text{
            Auth.auth().fetchSignInMethods(forEmail: email) { (signInMethods, error) in
                // This returns the same array as fetchProviders(forEmail:completion:) but for email
                // provider identified by 'password' string, signInMethods would contain 2
                // different strings:
                // 'emailLink' if the user previously signed in with an email/link
                // 'password' if the user has a password.
                // A user could have both.
                self.deactivateLoginButton()
                if let err = error{
                    let errorMessage = err.localizedDescription
                    self.showErrorMessageAction(errorMessage)
                }else{
                    if let methods = signInMethods{
                        if !methods.contains(EmailPasswordAuthSignInMethod){
                            self.activateLoginButton()
                        }else{
                            //email already exists in db
                            self.signInExistingUser()
                        }
                    }else{
                        //if email does not exist
                        self.createNewUser()
                    }
                }
            }
        }else{
            let errorMessage = "Please enter your email"
            showErrorMessageAction(errorMessage)
        }
    }
    
    fileprivate func createNewUser(){
        if let email = emailTextField?.text, let password = passwordTextField?.text{
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if let err = error {
                    let errorMessage = err.localizedDescription
                    self.showErrorMessageAction(errorMessage)
                }else{
                    if let result = result{
                        self.updateNewUserToDatabase(result, {
                            self.loadMainViewController()
                        })
                    }else{
                        let errorMessage = "The result does not exist"
                        self.showErrorMessageAction(errorMessage)
                    }
                }
            }
        }else{
            let errorMessage = "Email or password does not exist"
            showErrorMessageAction(errorMessage)
        }
    }
    
    fileprivate func updateNewUserToDatabase(_ result: AuthDataResult, _ completion: @escaping()->()){
        if let email = result.user.email{
            let uid = result.user.uid
            Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if !snapshot.exists(){
                    Database.database().reference().child("Users").child(uid).updateChildValues(["email": email], withCompletionBlock: { (error, ref) in
                        if let err = error{
                            let errorMessage = err.localizedDescription
                            self.showErrorMessageAction(errorMessage)
                        }else{
                            print("successfully created a new user")
                            completion()
                        }
                    })
                }else{
                    print("error: snapshot exists, user must be signed in")
                }
            }
        }
    }
    
    fileprivate func signInExistingUser(){
        if let email = emailTextField?.text, let password = passwordTextField?.text{
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if let err = error {
                    let errorMessage = err.localizedDescription
                    self.showErrorMessageAction(errorMessage)
                }else{
                    self.loadMainViewController()
                }
            }
        }
    }
    
    fileprivate func registerNewUser(_ response: MyProfileRequest.Response, _ completion: @escaping()->()){
        if let uid = Auth.auth().currentUser?.uid, let name = response.name{
            Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if !snapshot.exists(){
                    Database.database().reference().child("Users").child(uid).updateChildValues(["name": name])
                    print("created a new user")
                    completion()
                }else{
                    print("user already exists")
                    completion()
                }
            }
        }
    }
    
    fileprivate func loadMainViewController(){
        if let del = delegate{
            del.dismissLoginViewController()
        }
    }
    
    func activateLoginButton(){
        if let button = loginButton{
            button.isEnabled = true
        }
    }
    
    fileprivate func deactivateLoginButton(){
        if let button = loginButton{
            button.isEnabled = false
        }
    }
    
    fileprivate func showErrorMessageAction(_ message: String){
        if let del = delegate{
            del.showErrorMessage(message)
        }
    }
}
