//
//  RKDownloadManager.swift
//  RKBaseModule
//
//  Created by 刘爽 on 2023/2/1.
//

import UIKit
import Kingfisher

class RKDownloadManager: NSObject {
    typealias CompletionClosure = ((Error?, String) -> Void)
    typealias ProgressClosure = ((Progress) -> Void)
    
    static var sessionManager: SessionManager = {
        var configuration = SessionConfiguration()
        configuration.allowsCellularAccess = true
        let path = Cache.defaultDiskCachePathClosure("com.rokid.Cache")
        let cacahe = Cache("File", downloadPath: path)
        let manager = SessionManager("File", configuration: configuration, cache: cacahe, operationQueue: DispatchQueue(label: "com.rokid.SessionManager.operationQueue"))
        return manager
    }()
    
    static func cacheFile(fileUrlPath: String) -> Bool {
        return sessionManager.cache.filePath(url: fileUrlPath) != nil
    }
    
    static func downLoadFile(fileUrlPath: String, progress: ProgressClosure? = nil, completion: CompletionClosure? = nil) {
        sessionManager.download(fileUrlPath)?.progress { (task) in
            progress?(task.progress)
            
        }.completion { (task) in
            if task.status == .succeeded {
                completion?(nil, task.filePath)
                
            } else if task.status == .failed {
                completion?(task.error, "")
            }
        }
    }
    
    static func suspend(filePath: String) {
        sessionManager.suspend(filePath)
    }
    
    static func resume(filePath: String) {
        sessionManager.start(filePath)
    }
    
    static func cancel(filePath: String) {
        sessionManager.cancel(filePath)
    }
    
    static func videoSize(fileUrl: URL, complete: @escaping (String)->()) {
        
        var request = URLRequest(url: fileUrl)
        request.timeoutInterval = 10
        request.httpMethod = "HEAD"
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: SessionDelegate(), delegateQueue: nil)
        session.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
               let length = response.allHeaderFields["Content-Length"] as? String {
                DispatchQueue.main.async {
                    complete(length)
                }
            }
        }.resume()
    }
    
    static func trustHost(fileUrl: URL) {
        if var trustedHosts = ImageDownloader.default.trustedHosts {
            trustedHosts.insert(fileUrl.host ?? "")
            ImageDownloader.default.trustedHosts = trustedHosts
        } else {
            let trustedHosts: Set<String> = [fileUrl.host ?? ""]
            ImageDownloader.default.trustedHosts = trustedHosts
        }
    }
    
}

extension SessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
            return
        }

        completionHandler(.performDefaultHandling, nil)
    }
}
