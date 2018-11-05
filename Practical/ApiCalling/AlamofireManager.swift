//
//  AlamofireManager.swift
//  SharePhoto
//
//  Created by roycms on 2017/3/7.
//  Copyright © 2017年 北京三芳科技有限公司. All rights reserved.
//
/** NetworkManager demo
 let url : String = "aaa/1.html"
 
 let parameters: [String: String] = [
 "userId":"",
 "password":""]
 
 NetworkManager.get(url, parameters: parameters as [String : AnyObject], success: {(result: NSDictionary) -> Void in
 print ("Api Success : result is:\n \(result)")
 }, failure: {(error: NSDictionary?) -> Void in
 print ("Api Failure : error is:\n \(error)")
 })
**/

import UIKit
import Alamofire

class NetworkManager: NSObject {
    typealias apiSuccess = (_ result: Any?) -> Void
    typealias apiFailure = (_ error: Any?) -> Void
    
    static var sharedInstance = NetworkManager()
    
     func get(_ strURL: String, parameters: [String: Any], success:@escaping apiSuccess, failure:@escaping apiFailure) {
        Alamofire.request(strURL, parameters: parameters).responseJSON { (responseObject) -> Void in
            print("\nmakeGetCall:\n\(responseObject)")
            
            if responseObject.result.isSuccess {
                let JSON = responseObject.result.value
                if (JSON != nil) {
                    success(JSON!)
                }
                else {
                    failure(["error":"API Format Error", "statusCode":999])
                }
            }
            if responseObject.result.isFailure {
                let httpError: NSError = responseObject.result.error! as NSError
                let statusCode = httpError.code
                let error:NSDictionary = ["error" : httpError,"statusCode" : statusCode]
                failure(error)
            }
        }
    }
    
    
    
    func uploadImage(_ strURL: String, parameters: [String: Any]?,image: [UIImage]?,imageName:String, success:@escaping apiSuccess, failure:@escaping apiFailure) {
        
        Alamofire.upload(
            multipartFormData: { MultipartFormData in
                //    multipartFormData.append(imageData, withName: "user", fileName: "user.jpg", mimeType: "image/jpeg")
                
                for (key, value) in (parameters)! {
                    MultipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                }
                
                if image?.count != 0 {
                    for img in image! {
                        MultipartFormData.append(UIImagePNGRepresentation(img)!, withName: "profile_image", fileName: imageName, mimeType: "image/png")
                    }
                }

    
        }, to: strURL) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                    
                })

                upload.responseJSON { response in
                    
                    success(response.result.value)
                }
                
            case .failure(let encodingError):
                
                    failure(encodingError)
            }
        }
    }
    
     func post(_ strURL: String, parameters: [String: Any]?, success:@escaping apiSuccess, failure:@escaping apiFailure) {
        Alamofire.request( strURL, method: .post, parameters: parameters).responseJSON { (responseObject) -> Void in
            print("\nmakePostCall:\n\(responseObject)")
            
            if responseObject.result.isSuccess {
                let JSON = responseObject.result.value
                if (JSON != nil) {
                    success(JSON!)
                }
                else {
                    failure(["error":"API Format Error", "statusCode":999])
                }
            }
            if responseObject.result.isFailure {
                let httpError: NSError = responseObject.result.error! as NSError
                let statusCode = httpError.code
                let error:NSDictionary = ["error" : httpError,"statusCode" : statusCode]
                failure(error)
            }
        }
    }
}
