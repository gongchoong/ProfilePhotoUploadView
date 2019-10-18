//
//  LoginViewController.swift
//  ProfilePhotoUploadView
//
//  Created by chris davis on 8/26/19.
//  Copyright © 2019 chris davis. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import Firebase

class LoginViewController: UIViewController {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 34)
        label.text = "Profile Photo Upload View"
        label.textAlignment = .center
        return label
    }()
    
    let FBLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "custom_facebook_signin"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = " Email"
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = " Password"
        textField.isSecureTextEntry = true
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 5
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.init(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleEmailLogin), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    var mainViewController: MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.hidesBackButton = true
        setupLayout()
        checkIfLoggedIn()
    }
    
    func setupLayout(){
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 100),
            
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
            passwordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            loginButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8 * 51/315)
            ])
    }
    
    @objc func handleLogin(){
        deactivateLoginButton()
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.activateLoginButton()
                print(error)
            case .cancelled:
                self.activateLoginButton()
                print("User cancelled login.")
            case .success:
                print("Logged in!")
                self.loginFirebase()
            }
        }
    }
    
    @objc func handleEmailLogin(){
        if let email = emailTextField.text{
            Auth.auth().fetchSignInMethods(forEmail: email) { (signInMethods, error) in
                // This returns the same array as fetchProviders(forEmail:completion:) but for email
                // provider identified by 'password' string, signInMethods would contain 2
                // different strings:
                // 'emailLink' if the user previously signed in with an email/link
                // 'password' if the user has a password.
                // A user could have both.
                if let err = error{
                    print(err.localizedDescription)
                }else{
                    if let methods = signInMethods{
                        if !methods.contains(EmailPasswordAuthSignInMethod){
                            print("user can sign in with email/password")
                        }else{
                            self.signInExistingUser()
                        }
                    }else{
                        self.createNewUser()
                    }
                }
            }
        }
    }
    
    fileprivate func createNewUser(){
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if let err = error {
                    print(err.localizedDescription)
                }else{
                    if let result = result{
                        self.updateNewUserToDatabase(result, {
                            self.loadMainViewController()
                        })
                    }else{
                        print("error: result DNE")
                    }
                }
            }
        }else{
            print("email or password dne")
        }
    }
    
    fileprivate func updateNewUserToDatabase(_ result: AuthDataResult, _ completion: @escaping()->()){
        if let email = result.user.email{
            let uid = result.user.uid
            Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if !snapshot.exists(){
                    Database.database().reference().child("Users").child(uid).updateChildValues(["email": email], withCompletionBlock: { (error, ref) in
                        if let err = error{
                            print(err.localizedDescription)
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
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if let err = error {
                    print(err.localizedDescription)
                }else{
                    self.loadMainViewController()
                }
            }
        }
    }
    
    fileprivate func loginFirebase(){
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.authenticationToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("user is signed in to firebase")
            self.getGraphData(completion: { (response) in
                self.registerNewUser(response, {
                    self.loadMainViewController()
                })
            })
        }
    }
    
    fileprivate func getGraphData(completion: @escaping(MyProfileRequest.Response)->()){
        let connection = GraphRequestConnection()
        connection.add(MyProfileRequest()) { response, result in
            switch result {
            case .success(let response):
                completion(response)
            case .failed(let error):
                print("Custom Graph Request Failed: \(error)")
            }
        }
        connection.start()
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

    fileprivate func checkIfLoggedIn(){
        if Auth.auth().currentUser != nil{
            print("already logged in!!!")
            loadMainViewController()
        }
    }
    
    fileprivate func prepareMainViewModel(){
        if let vc = self.mainViewController{
            vc.setupViewModel()
        }
    }
    
    fileprivate func loadMainViewController(){
        let mainViewController = MainViewController()
        navigationController?.pushViewController(mainViewController, animated: true)
        activateLoginButton()
    }
    
    fileprivate func activateLoginButton(){
        self.FBLoginButton.isEnabled = true
    }
    
    fileprivate func deactivateLoginButton(){
        self.FBLoginButton.isEnabled = false
    }
}
