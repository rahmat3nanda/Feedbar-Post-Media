//
//  MediaCell.swift
//  feedbar
//
//  Created by Rahmat Trinanda Pramudya Amar on 21/07/22.
//

import Foundation
import UIKit

class MediaCell: UICollectionViewCell{
    @IBOutlet var indexLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    static var name = "MediaCell"
    static var id = "mediaCell"
    
    private var media: MediaModel!
    
    func setupMedia(media: MediaModel){
        self.media = media
        indexLabel.text = media.message
    }
}
