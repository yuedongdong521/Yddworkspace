//
//  NetWorkRequest.swift
//  Yddworkspace
//
//  Created by ispeak on 2017/7/28.
//  Copyright © 2017年 QH. All rights reserved.
//

import Foundation

public class NetWorkRequest {
    
    func getNetworkRequest(requestUrlStr urlStr:String, resultBlock:@escaping (_ resultdata:Data?, _ resultresponse:URLResponse?, _ resulterror:Error?) -> Void) {
        let session = URLSession.shared
        let url = URL.init(string: urlStr)!
        
        
        let tast = session.dataTask(with: URLRequest.init(url: url)) { (data, response, error) in
            resultBlock(data, response, error)
        }
        tast.resume()
    }
    
    func postNetworkRequest(requestUrlStr urlStr:String, parameters parametDic:NSDictionary?, resultBlock:@escaping (Data?, Error?)->Void) -> Void {
        let session = URLSession.shared
        let url:URL? = URL.init(string: urlStr)
        var request = URLRequest.init(url: url!, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "POST"
        if parametDic != nil {
            request.httpBody = getBodyParameter(parameterDic: parametDic!)
        }
        
        session.dataTask(with: request) { (data, response, error) in
            resultBlock(data, error)
        }
        
    }
    
    func getBodyParameter(parameterDic:NSDictionary) -> Data? {
        let keyArray:NSArray = parameterDic.allKeys as NSArray;
        var parameterStr:String? = nil
        for i in 0..<keyArray.count {
            let keyStr = keyArray.object(at: i) as! String
            let valueStr = parameterDic.object(forKey: keyStr) as! String
            if i == 0 {
                parameterStr = keyStr + "=" + valueStr
            } else {
                parameterStr = parameterStr! + "&" + keyStr + "=" + valueStr
            }
        }
        let data = parameterStr?.data(using: String.Encoding.utf8)
        return data
    }
    
}
