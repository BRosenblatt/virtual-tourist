//
//  FlickrAPIClient.swift
//  virtual-tourist
//
//  Created by Becca Kauper on 9/13/23.
//

import Foundation
import UIKit

class FlickrAPIClient {

    static let apiKey = "970768dc71c88bce017f3e6f8173237f"
    static let photosPerPage = 20
    static let mediaType = "photos"
    
    enum Endpoint {
        static let baseURL = "https://www.flickr.com/services/rest/"
        static let searchPhotoMethod = "flickr.photos.search"
        
        case getPhotos(lat: Double, long: Double, page: Int)
        case getImageFile(serverID: String, id: String, secretID: String)
        
        var stringValue: String {
            switch self {
            case .getPhotos(let lat, let long, let page):
                return Endpoint.baseURL + "?"
                + "&method=\(Endpoint.searchPhotoMethod)"
                + "&api_key=\(FlickrAPIClient.apiKey)"
                + "&privacy_filter=1"
                + "&safe_search=1"
                + "&media=\(FlickrAPIClient.mediaType)"
                + "&lat=\(lat)"
                + "&lon=\(long)"
                + "&per_page=\(FlickrAPIClient.photosPerPage)"
                + "&page=\(page)"
                + "&format=json&nojsoncallback=1"
            case .getImageFile(let serverID, let id, let secretID):
                return "https://live.staticflickr.com/"
                + "\(serverID)/"
                + "\(id)"
                + "_\(secretID)"
                + ".jpg"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // MARK: - Call the searchPhotoMethod
    
    class func getPhotosList(lat: Double, long: Double, page: Int, completion: @escaping (PhotoObject?, Error?) -> Void) {
        let photosEndpoint = Endpoint.getPhotos(lat: lat, long: long, page: page).url
        let task = URLSession.shared.dataTask(with: photosEndpoint) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(SearchPhotosResponse.self, from: data)
                let result = response.photos
                DispatchQueue.main.async {
                    completion(result, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Call the url for each photo. Need server id, secret id, and photo id from the SearchPhotosResponse to construct the url
    
    class func requestImageFile(serverID: String?, secretID: String?, id: String?, completion: @escaping (UIImage?, Error?) -> Void) {
        guard let serverID, let secretID, let id else {
            return
        }
        let url = Endpoint.getImageFile(serverID: serverID, id: id, secretID: secretID).url
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                completion(image, nil)
            }
        }
        task.resume()
    }
}
