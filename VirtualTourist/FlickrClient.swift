//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Laura Evans on 2/15/16.
//  Copyright © 2016 Laura Evans. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    static let sharedInstance = FlickrClient()
    
    func getImagesByLatLong(completionHandler: (success: Bool, imagesArray: [String], error: String?) -> Void) {
        
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=2128ee64c0e22f255d092838a4866afc&page=1&extras=url_m&lat=32.776664&lon=-96.796988&format=json&nojsoncallback=1")
        let request = NSURLRequest(URL: url!)
        
        print(request)
        
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
            
            // GUARD: was there an error?
            guard (error == nil) else {
                print("there was an error with your request: \(error)")
                return
            }
            
            // GUARD: Did we get a successful response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            // Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            // GUARD: Did Flickr return an error?
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            // GUARD: is photos key in our result?
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary else {
                print("Cannot find keys in photos in \(parsedResult)")
                return
            }
            
            // GUARD: Is the photo key in the photosDictionary?
            guard let photosArray = photosDictionary["photo"] as? [[String:AnyObject]] else {
                print("Cannot find key photo in photos array")
                return
            }
            
            var images = [String]()
            
            for photo in photosArray {
                images.append( photo["url_m"] as! String )
            }
            
            completionHandler(success: true, imagesArray: images, error: nil)
        }
        
        task.resume()
        
    }
    
    
    
}
