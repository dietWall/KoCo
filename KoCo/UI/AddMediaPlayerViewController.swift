//
//  AddMediaPlayerViewController.swift
//  KoCo
//
//  Created by admin on 19.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit

class AddMediaPlayerViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add Media Center"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        print("cancel pressed: leaving vc")
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonFinished(_ sender: UIButton) {
        
        print("nameTextField: \(String(describing: nameTextField.text))" )
        print("url: \(String(describing: urlTextField.text))" )
        print("username: \(String(describing: userNameTextField.text))" )
        print("password: \(String(describing: passwordTextField.text))" )
        
        //Create Kodi
        //If it fails, show a message: url is incorrect, no segue
        //try to connect with kodi:
        //if it fails: should I save the player??
        //yes: save
        //exit
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
