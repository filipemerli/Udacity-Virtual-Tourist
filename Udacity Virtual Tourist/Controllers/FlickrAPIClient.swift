//
//  FlickrAPIClient.swift
//  Udacity Virtual Tourist
//
//  Created by Filipe Merli on 12/03/2018.
//  Copyright © 2018 Filipe Merli. All rights reserved.
//

import Foundation

class FlickrAPIClient: NSObject {
    
    // MARK: Properties
    
    var session = URLSession.shared
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: GET
    func taskForGetMethod(completionHandlerForGetMethod: @escaping(_ result: AnyObject?, _ error: String?)-> Void) {
        let methodParameters = [
            "method": "flickr.photos.search",
            "api_key": FlickrConstants.myKey,
            "bbox": FlickrConstants.bboxRange,
            "safe_search": "1",
            "extras": "url_m",
            "format": "json",
            "nojsoncallback": "1"
        ]
        let request = URLRequest(url: flickrURLFromParameters(methodParameters as [String:AnyObject]))
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandlerForGetMethod(nil, error?.localizedDescription)
                return
            }
            self.convertDataWithCompletionHandler(data!) { results, error in
                guard let stat = results!["stat"] as? String, stat == "ok" else {
                    print("Flickr API returned an error. See error code and message in \(String(describing: results))")
                    completionHandlerForGetMethod(nil, "No results from Flickr")
                    return
                }
                guard let photosDict = results!["photos"] as? [String:AnyObject] else {
                    print("Cannot find key photos in \(String(describing: results))")
                    completionHandlerForGetMethod(nil, "No Photos")
                    return
                }
                
                guard let photosArray = photosDict["photo"] as? [[String: AnyObject]] else {
                    print("Cannot find key photo in \(photosDict)")
                    completionHandlerForGetMethod(nil, "No photo")
                    return
                }
                if photosArray.count == 0 {
                    print("No Photos Found. Search Again.")
                    completionHandlerForGetMethod(nil, "No photos found")
                    return
                } else {
                    let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                    let photoDict = photosArray[randomPhotoIndex] as [String: AnyObject]
                    guard let imageUrlString = photoDict["url_m"] as? String else {
                        print("Cannot find key url_m in \(photoDict)")
                        return
                    }
                    completionHandlerForGetMethod(imageUrlString as AnyObject, nil)
                }
            }
        }
        task.resume()
    }
    
    // MARK: Parse JSON
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // MARK:
    func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> FlickrAPIClient{
        struct Singleton{
            static var sharedInstance = FlickrAPIClient()
        }
        return Singleton.sharedInstance
    }
    
}
