//
//  PhotoAlbumCollectionViewController.swift
//  virtual-tourist
//
//  Created by Becca Kauper on 9/7/23.
//

import UIKit
import CoreData

class PhotoAlbumCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var pin: Pin!
    var photos: [Photo] = []
    var dataController: DataController!
    var photoIndex: PhotoIndex!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        setUpFlowLayout()
        fetchPhotos()
    }
    
    func setUpFlowLayout() {
        let space: CGFloat = 3.0
        let width = (collectionView.frame.size.width - (2 * space)) / 3.0
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
        let photoIndexForPin = fetchPhotoIndexForPinFromCoreData()
        
        if photosForPin.isEmpty || photoIndexForPin == nil {
            FlickrAPIClient.getPhotosList(lat: pin.latitude, long: pin.longitude, page: 1, completion: handlePhotosResponse)
            print("fetching from api")
        } else {
            photos = photosForPin
            photoIndex = photoIndexForPin
            print("loading from core data")
        }
    }
    
    func handlePhotosResponse(data: PhotoObject?, error: Error?) {
        guard let data = data else {
            print("Something went wrong")
            return
        }
        
        for photoData in data.photo {
            let photo = Photo(context: self.dataController.viewContext)
            photo.id = photoData.id
            photo.secret = photoData.secret
            photo.server = photoData.server
            photo.title = photoData.title
            photo.pinIdentifier = self.pin.identifier
            photo.imageData = nil
        }
        
        let photoIndex = PhotoIndex(context: self.dataController.viewContext)
        photoIndex.pages = Int64(data.pages)
        photoIndex.pinIdentifier = self.pin.identifier
        self.photoIndex = photoIndex
        
        try? self.dataController.viewContext.save()
        photos = fetchPhotosForPinFromCoreData()
        collectionView.reloadData()
    }
    
    @IBAction func reloadPhotosButton(_ sender: Any) {
        guard photoIndex.pages > 1 else {
            return
        }
        
        // remove all photos from core data
        for photo in photos {
            dataController.viewContext.delete(photo)
        }
        
        // remove all photos from photos array
        photos.removeAll()
        
        // save
        try? dataController.viewContext.save()
        
        // randomly generate page number in getPhotosList call to load new set of 20 photos into the collection view and core data
        let randomPage = randomlyGeneratePageNumber(maxPageCount: Int(photoIndex.pages))
        
        FlickrAPIClient.getPhotosList(lat: pin.latitude, long: pin.longitude, page: randomPage, completion: handlePhotosResponse(data:error:))
        print("fetching page number: \(randomPage)")
    }
    
    func randomlyGeneratePageNumber(maxPageCount: Int) -> Int {
        let randomPageNumber = Int.random(in: 2...maxPageCount)
        
        return randomPageNumber
    }
}


// MARK: - Implement Collection View data source methods

extension PhotoAlbumCollectionViewController {
    
    // MARK: - Get photo count
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    // MARK: Set up custom cell
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell

        if photos.count >= indexPath.item, let imageData = photos[indexPath.item].imageData {
            cell.photoImageView.image = UIImage(data: imageData)
        } else {
            let photo = photos[indexPath.item]
            FlickrAPIClient.requestImageFile(serverID: photo.server, secretID: photo.secret, id: photo.id) { image, error in
                guard let image = image else {
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
        let predicate = NSPredicate(format: "pinIdentifier == %@", pin.identifier ?? "")
        fetchRequest.predicate = predicate
        do {
            let photos = try dataController.viewContext.fetch(fetchRequest)
            return photos
        } catch {
            print("Coudn't fetch \(error)")
            return []
        }
    }
    
    func fetchPhotoIndexForPinFromCoreData() -> PhotoIndex? {
        let fetchRequest = PhotoIndex.fetchRequest()
        let predicate = NSPredicate(format: "pinIdentifier == %@", pin.identifier ?? "")
        fetchRequest.predicate = predicate
        do {
            let photoIndex = try dataController.viewContext.fetch(fetchRequest)
            return photoIndex.first
        } catch {
            print("Coudn't fetch \(error)")
            return nil
        }
    }
        
    // MARK: - Delete photo when tapped
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataController.viewContext.perform {
            // delete photo
            let photoToDelete = self.photos[indexPath.item]
            self.photos.remove(at: indexPath.item)
            self.collectionView.deleteItems(at: [indexPath])
            self.dataController.viewContext.delete(photoToDelete)
            
            // save
            try? self.dataController.viewContext.save()
        }
    }
}
