//
//  SimpleWebService.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/8/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import UIKit

class SimpleWebService {
    private let clientId = "309c9d6c844476c"
    private let baseUrl = "https://api.imgur.com/3/image"
    
    static let shared = SimpleWebService()
    private init() {}
    
    func uploadImage(withData imageData: Data, aftermathClosure: @escaping (String?, Date?) -> Void) {
        let url = URL(string: baseUrl);
        let request = NSMutableURLRequest(url: url!);
        request.httpMethod = "POST"
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Client-ID " + clientId, forHTTPHeaderField: "Authorization")
        
        let body = NSMutableData()
        body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Disposition: form-data; name=\"image\"\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(imageData)
        body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        
        request.httpBody = body as Data
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            var success = false
            defer {
                if !success {
                    aftermathClosure(nil, nil)
                }
            }
            if let data = data {
                if let resultObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("success")
                    //print(resultObject)
                    if let resultDic = resultObject as? Dictionary<String, Any> {
                        if let dataDic = resultDic["data"] as? Dictionary<String, Any> {
                            if let dateTimeSeconds = dataDic["datetime"] as? TimeInterval, let imageWebUrl = dataDic["link"] as? String {
                                let dateTime = Date(timeIntervalSince1970: dateTimeSeconds)
                                aftermathClosure(imageWebUrl, dateTime)
                                success = true
                            }
                        }
                    }
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
    }
}
