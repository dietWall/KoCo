//
//  MusicLibraryCell.swift
//  KoCo
//
//  Created by dietWall on 18.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit

protocol MusikLibraryCellDelegate{
    func addButtonPressed(cell: MusicLibraryCell)
    
    func playButtonPressed(cell: MusicLibraryCell)
}



class MusicLibraryCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var mediaId : LibraryId?
    
    var delegate : MusikLibraryCellDelegate?
    

    @IBAction func addButtonPressed(_ sender: UIButton) {
        delegate?.addButtonPressed(cell: self)
    }
    
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        delegate?.playButtonPressed(cell: self)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
