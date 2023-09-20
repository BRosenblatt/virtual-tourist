//
//  PhotoAlbumCollectionViewController.swift
//  virtual-tourist
//
//  Created by Becca Kauper on 9/7/23.
//

import UIKit
import CoreData

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
    
    // MARK: - Get list of photos per pin based on location
    
    func fetchPhotos() {
        let photosForPin = fetchPhotosForPinFromCoreData()
        
        if photosForPin.isEmpty {
            FlickrAPIClient.getPhotosList(lat: pin.latitude, long: pin.longitude, completion: handlePhotosResponse)
            print("fetching from api")
        } else {
            photos = photosForPin
            print("loading from core data")
        }
    }
    
    func handlePhotosResponse(data: [PhotoData]?, error: Error?) {
        guard let data = data else {
            print("Something went wrong")
            return
        }
        for photoData in data {
            let photo = Photo(context: self.dataController.viewContext)
            photo.id = photoData.id
            photo.secret = photoData.secret
            photo.server = photoData.server
            photo.pinIdentifer = self.pin.identifier
            photo.imageData = nil
        }
        try? self.dataController.viewContext.save()
        photos = fetchPhotosForPinFromCoreData()
        collectionView.reloadData()
    }
}


// MARK: - Implement Collection View data source methods

extension PhotoAlbumCollectionViewController {
    
    // MARK: - Get photo count
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    // MARK: Set up custom cell
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        if photos.count >= indexPath.item, let imageData = photos[indexPath.item].imageData {
            cell.photoImageView.image = UIImage(data: imageData)
        } else {
            let photo = photos[indexPath.item]
            FlickrAPIClient.requestImageFile(serverID: photo.server, secretID: photo.secret, id: photo.id) { image, error in
                guard let image = image else {
                    print("Couldn't fetch image")
                    return
                }
                self.saveImageData(image: image, photo: photo)
                cell.photoImageView.image = image
            }
        }
        return cell
    }
    
    
    // MARK: - Save image data for photo
    
    func saveImageData(image: UIImage, photo: Photo) {
        dataController.viewContext.perform {
            photo.imageData = image.jpegData(compressionQuality: 1.0)
            try? self.dataController.viewContext.save()
        }
    }
    
    // MARK: - Get a saved photo from Core Data
    
    func fetchPhotosForPinFromCoreData() -> [Photo] {
        let fetchRequest = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pinIdentifer == %@", pin.identifier ?? "")
        fetchRequest.predicate = predicate
        do {
            let photos = try dataController.viewContext.fetch(fetchRequest)
            return photos
        } catch {
            print("Coudn't fetch \(error)")
            return []
        }
    }
    
    // MARK: - Delete photo when tapped
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = photos[indexPath.item]
        photos.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
        dataController.viewContext.delete(photoToDelete)
    }
}
