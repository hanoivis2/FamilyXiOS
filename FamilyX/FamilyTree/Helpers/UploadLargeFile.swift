//
//  UploadLargeFile.swift
//  Techres - TMS
//
//  Created by lephuhao on 7/17/20.
//  Copyright © 2020 ALOAPP. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper


class Networking {
  static let sharedInstance = Networking()
  public var sessionManager: Alamofire.SessionManager
  public var backgroundSessionManager: Alamofire.SessionManager
  private init() {
    self.sessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
    self.backgroundSessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: "com.lava.app.backgroundtransfer"))
  }
}

class ImageUploadClient {
    class func uploadWithUrl(serverUrl: URL, headers: HTTPHeaders, videoURL: URL, filename: String, progressing: ((Double) -> Void)?, success: ((DataResponse<Any>) -> Void)?, failure: ((Error) -> Void)?) {
    
        Networking.sharedInstance.backgroundSessionManager.upload(multipartFormData: { (multipartData) in
            multipartData.append(videoURL, withName: "file", fileName: filename, mimeType: "image")
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: serverUrl, method: .post, headers: headers, encodingCompletion: { encodingResult in
          
            switch (encodingResult) {
            
            case .success(let request, _, _):
                
                request.uploadProgress(closure: { (progress) in
                    print("upload progress: \(progress.fractionCompleted)")
                    progressing!(progress.fractionCompleted)
                })
  
                request.responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success( _):
                        
                        success?(response)
                        
                    case .failure(let error):
                        failure?(error)
                    }
                })
            
            case .failure(let error):
                failure?(error)
            
            }
        })
    
  }
    
    class func  uploadWithData(serverUrl: URL, headers: HTTPHeaders, fileData: Data, filename: String, progressing: ((Double) -> Void)?, success: ((DataResponse<Any>) -> Void)?, failure: ((Error) -> Void)?) {
    
        Networking.sharedInstance.backgroundSessionManager.upload(multipartFormData: { (multipartData) in
            multipartData.append(fileData, withName: "send_file", fileName: filename, mimeType: "image")
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: serverUrl, method: .post, headers: headers, encodingCompletion: { encodingResult in
            
            switch (encodingResult) {
            case .success(let request, _, _):
                
                request.uploadProgress(closure: { (progress) in
                    print("upload progress: \(progress.fractionCompleted)")
                    progressing!(progress.fractionCompleted)
                })
        
                request.responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success( _):
                        
                        success?(response)
                        
                      case .failure(let error):
                        failure?(error)
                    }
                })
            
            case .failure(let error):
              failure?(error)
            
          }
        }) 
    }
}
