//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let pass = passwordTextfield.text {
            Auth.auth().createUser(withEmail: email, password: pass) {authResult, error in
                if let err = error {
                    print(err.localizedDescription)
                    self.errorLabel.text = err.localizedDescription
                    self.errorLabel.isHidden = false
                }
                else {
                    //Go to ChatViewController
                    self.performSegue(withIdentifier: constants.registerSegue, sender: self)
                }
            }
        }
         
    }
}
