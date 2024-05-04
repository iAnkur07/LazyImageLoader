//
//  ImagesCell.swift
//  LazyImageLoader
//
//  Created by Ankur on 04/05/24.
//

import UIKit

class ImagesCell: UICollectionViewCell {
    
    static let cellId = "ImagesCell"

    @IBOutlet weak var postImageView: UIImageView!
    
    var url: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postImageView.layer.cornerRadius = 8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
        postImageView.cancelRequest()
    }

}
