//
//  AddMediaPlayerViewController.swift
//  KoCo
//
//  Created by admin on 19.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit




class AddMediaPlayerViewController: UIViewController, KodiPlayerLoaderProtocol {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    //weak var receiver : KodiAddDelegateProtocol?
    
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
        let player = KodiPlayer(name: (nameTextField.text)!, url: urlTextField.text!, user: userNameTextField.text, password: passwordTextField.text)
        
        if(player != nil){
            print("saving Player")
            appendPlayerToFile(player: player!)         //check against not nil was done
        }
        else{
            //If it fails, show a message: url is incorrect, no segue
            showAlert(title: "URL is incorrect", message: urlTextField.text! + "is an incorrect URL")
        }
        
        
        //try to connect with kodi:
        //if it fails: Question to the user: should I save the player??
        //yes: save
        //exit
        
    
    }
    
    private func appendPlayerToFile(player: KodiPlayer){
        var savedPlayers = loadData()
        
        savedPlayers += [player]
        
        saveToFile(players: savedPlayers)
    
    }
    
    private func saveToFile(players: [KodiPlayer]){
        var url: URL
        
        do{
            url = try FileManager.default.url(
                for: FileManager.SearchPathDirectory.applicationDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
            
           
            
            url.appendPathComponent("players.json")
            
            print(url)
            
            let coder = JSONEncoder()
            
            let data = try coder.encode(players)
            
            try data.write(to: url)
            
        }
        catch let error{
            print("Filemanager hat geschmissen: \(error)")
        }
        
    }
    
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        
        var alertWindow : UIWindow!
        alertWindow = UIWindow.init(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController.init()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true)
    }
    

    // MARK: - Navigation
/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 */

}
