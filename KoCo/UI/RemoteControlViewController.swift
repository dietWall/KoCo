
//
//  RemoteControlViewController.swift
//  KoCo
//
//  Created by dietWall on 30.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit

class RemoteControlViewController: UIViewController {
    
    var player : KodiPlayer? = nil
    
    @IBOutlet var directionKeys: [UIButton]!
    
    @IBAction func directionKeyPressed(_ sender: UIButton) {
        
        // Can we get rid of this switch somehow??
        
        let title = sender.title(for: .normal)
        
        switch(title)
        {
        case "up":
            player?.navigate(to: .Up)
        case "down":
            player?.navigate(to: .Down)
        case "left":
            player?.navigate(to: .Left)
        case "right":
            player?.navigate(to: .Right)
        case "Enter":
            player?.navigate(to: .Enter)
        case "Back":
            player?.navigate(to: .Back)
        default:
            print("unknown button title : \(String(describing: title))")
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
