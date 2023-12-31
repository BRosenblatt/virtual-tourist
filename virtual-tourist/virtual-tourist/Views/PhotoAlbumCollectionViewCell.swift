//
//  PhotoAlbumCollectionViewCell.swift
//  virtual-tourist
//
//  Created by Becca Kauper on 9/12/23.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = UIImage(systemName: "photo.circle.fill")
    }
}
