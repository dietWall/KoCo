//
//  AddMediaPlayerViewController.swift
//  KoCo
//
//  Created by dietWall on 19.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit

class AddMediaPlayerViewController: UIViewController{
    
    private lazy var authentificationFailedNotification = Notification(title: "Authentification failed!", alertStyle: .alert, message: "Player rejected username or password", actions: [NotificationButton(text: "Ok", style: .default)] )
    
    private lazy var  successNotification = Notification(title: "Success!", alertStyle: .alert, message: "Successfully saved player", actions: [NotificationButton(text: "Ok", style: .default)] )
    
    private lazy var invalidUrlNotification = Notification(title: "Invalid URL", alertStyle: .alert, message: "The given url is incorrect", actions: [NotificationButton(text: "Ok", style: .default)] )

    //private lazy var saveButton = AlertButton(button: )
    
    //private let playerNotReachable = Alert()
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add Media Center"
        
        //Disappearing Keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing)))
    }
    
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func checkPlayerAvailable(_ sender: UIButton) {
        
        //Create Player
        guard let player = KodiPlayer(name: (nameTextField.text)!, url: urlTextField.text!, user: userNameTextField.text, password: passwordTextField.text) else{
            //Set Cursor in the UrlTextField, last character, so user can modify the url
            self.invalidUrl()
            return
        }
        
        self.showSpinner(onView: self.view)
        
        player.getVersion(completion: { tmpVersion, response, error in
            
            self.removeSpinner()
            
            if error == nil{
                
                switch(response?.statusCode)
                {
                case -1001:
                    self.createAlarmPlayerNotReachable(player: player)
                case 401:
                    //TODO: Show: User/Password required!!!
                    self.createNotification(notification: self.authentificationFailedNotification)
                    self.jumpToTextField(textField: self.userNameTextField)
                case 200:
                    self.appendPlayerToFile(player: player)
                    self.createNotification(notification: self.successNotification)

                default:
                    print("\(self) not implemented error: statuscode: \(String(describing: response?.statusCode))")
                    //Everything else defaults to invalid url
                    self.invalidUrl()
                    break;
                }
            }
            else{
                print("Error != nil: \(String(describing: error))")
                print("Statuscode: \(String(describing: response?.statusCode))")
                self.createAlarmPlayerNotReachable(player: player)
            }
            
            })

    }

    
    private func invalidUrl(){
        createNotification(notification: invalidUrlNotification)
        jumpToTextField(textField: urlTextField)
    }
    
    
    
    private func createAlarmPlayerNotReachable(player: KodiPlayer){
        //TODO: It would be nice to make this also via Notification Extension
        let alert = UIAlertController(title: "Not Reachable", message: "Was not able to contact Kodi, Do you want to save anyway?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: { _ in
            self.appendPlayerToFile(player: player)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .default, handler: { _ in
            //dont save, clear the fields
            self.urlTextField.text = ""
        }))

        //Present from the main queue
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }

    
    private func appendPlayerToFile(player: KodiPlayer){
        var savedPlayers = [KodiPlayer]()
        savedPlayers.loadData()
        savedPlayers += [player]
        savedPlayers.save()
    }

}
