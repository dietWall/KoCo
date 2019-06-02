//
//  KodiPlayerTabBarViewController.swift
//  KoCo
//
//  Created by dietWall on 02.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit

class KodiPlayerTabBarViewController: UITabBarController, KodiPlayerViewController {
    
    
    var player: KodiPlayer?{
        didSet{
            print("TabBarViewController: player: didSet")
            guard let vc = self.viewControllers as? [KodiPlayerViewController] else {
                print("KodiTabBarViewController Error: children are not castable to [KodiPlayerViewController]")
                return
            }
            
            for var v in vc{
                v.player = player
            }
            
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
