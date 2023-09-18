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
    var photoData: [PhotoData] = []
    var dataController: DataController!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setUpFlowLayout()
        fetchPhotos()
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
    
    func fetchPhotos() {
        FlickrAPIClient.getPhotosList(lat: pin.latitude, long: pin.longitude, completion: handlePhotosResponse)
    }
    
    func handlePhotosResponse(data: [PhotoData]?, error: Error?) {
        guard let data = data else {
            print("Something went wrong")
            return
        }
        photoData = data
        collectionView.reloadData()
    }
}
    
    
extension PhotoAlbumCollectionViewController {
    // MARK: - Get photo count
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoData.count
    }
    
    // MARK: Set up custom cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        let photo = photoData[indexPath.row]
        FlickrAPIClient.requestImageFile(serverID: photo.server, secretID: photo.secret, id: photo.id) { image, error in
            guard let image = image else {
                print("Couldn't fetch image")
                return
            }
            cell.photoImageView.image = image
        }
        return cell
    }
    
    // MARK: - Delete photo when tapped
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let photoToDelete = IndexPath(item: indexPath.item, section: 0)
//        photoData.remove(at: photoToDelete.item)
//        collectionView.deleteItems(at: [photoToDelete])
    }
}
