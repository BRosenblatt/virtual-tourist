//
//  PhotoAlbumCollectionViewController.swift
//  virtual-tourist
//
//  Created by Matt Kauper on 9/7/23.
//

import UIKit

class PhotoAlbumCollectionViewController: UICollectionViewController {
    var pin: Pin!
    var photos: [Photo] = []
    var dataController: DataController!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setUpFlowLayout()
    }
    
    func setUpFlowLayout() {
        let space: CGFloat = 3.0
        let width = (view.frame.size.width - (2 * space)) / 3.0
        let height = width

        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSize(width: width, height: height)
        flowLayout.estimatedItemSize = .zero
        collectionView.collectionViewLayout = flowLayout
    }
    
    // MARK: - Get photo count
    
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return photos.count
//    }
//
//    // MARK: Set up custom cell
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
//        let photo = photos[indexPath.row]
//
//        cell.photoImageView.image = photo.data
//
//        return cell
//    }
//
//    // MARK: - When photo is selected, delete and replace with new photo
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        <#code#>
//    }
}



