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
        view.addSubview(FBLoginButton)
        NSLayoutConstraint.activate([
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 100),
            
            FBLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            FBLoginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            FBLoginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            FBLoginButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8 * 51/315)
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
