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
    
    fileprivate let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "blankImage")
        return imageView
    }()
    
    fileprivate let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.9
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Profile Photo Upload View"
        label.font = UIFont(name: "Lato-Bold", size: 26)
        label.textColor = UIColor.white
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
        textField.layer.borderColor = UIColor.white.cgColor
        textField.backgroundColor = UIColor.white
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = " Password"
        textField.isSecureTextEntry = true
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.white.cgColor
        textField.backgroundColor = UIColor.white
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
    }
    
    func setupLayout(){
        
        blurEffectView.frame = backgroundImageView.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
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
    
    @objc func handleEmailLogin(){
        if let email = emailTextField.text{
            Auth.auth().fetchSignInMethods(forEmail: email) { (signInMethods, error) in
                // This returns the same array as fetchProviders(forEmail:completion:) but for email
                // provider identified by 'password' string, signInMethods would contain 2
                // different strings:
                // 'emailLink' if the user previously signed in with an email/link
                // 'password' if the user has a password.
                // A user could have both.
                self.deactivateLoginButton()
                if let err = error{
                    print(err.localizedDescription)
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
        if let mainController = mainViewController{
            print("loading mainview...")
            mainController.checkIfLoggedIn()
            navigationController?.popViewController(animated: true)
            activateLoginButton()
        }else{
            print("not loading mainview...")
        }
    }
    
    fileprivate func activateLoginButton(){
        self.loginButton.isEnabled = true
    }
    
    fileprivate func deactivateLoginButton(){
        self.loginButton.isEnabled = false
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
}
