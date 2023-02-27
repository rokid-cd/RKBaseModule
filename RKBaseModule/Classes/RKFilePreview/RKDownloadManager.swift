//
//  RKDownloadManager.swift
//  RKBaseModule
//
//  Created by 刘爽 on 2023/2/1.
//

import UIKit
import Kingfisher

public class RKDownloadManager: NSObject {
    public typealias CompletionClosure = ((Error?, String) -> Void)
    public typealias ProgressClosure = ((Progress) -> Void)
    
    static var sessionManager: SessionManager = {
        var configuration = SessionConfiguration()
        configuration.allowsCellularAccess = true
        let manager = SessionManager("Rokid", configuration: configuration, operationQueue: DispatchQueue(label: "com.rokid.SessionManager.operationQueue"))
        return manager
    }()
    
    public static func cacheFilePath(fileUrl: URL) -> String? {
        return sessionManager.cache.filePath(url: fileUrl)
    }
    
    public static func isCache(fileUrl: URL) -> Bool {
        guard let cachePath = cacheFilePath(fileUrl: fileUrl) else { return false }
        return FileManager.default.fileExists(atPath: cachePath)
    }
    
    public static func downLoadFile(fileUrl: URL, progress: ProgressClosure? = nil, completion: CompletionClosure? = nil) {
        sessionManager.download(fileUrl)?.progress { task in
            progress?(task.progress)
            
        }.success({ task in
            completion?(nil, task.filePath)
        }).failure({ task in
            if task.status == .failed {
                completion?(task.error, "")
            }
        })
    }
    
    public static func suspend(fileUrl: URL) {
        sessionManager.suspend(fileUrl)
    }
    
    public static func resume(fileUrl: URL) {
        sessionManager.start(fileUrl)
    }
    
    public static func cancel(fileUrl: URL) {
        sessionManager.cancel(fileUrl)
    }    
    
    public static func trustHost(fileUrl: URL?) {
        guard let url = fileUrl else { return }
        if var trustedHosts = ImageDownloader.default.trustedHosts {
            trustedHosts.insert(url.host ?? "")
            ImageDownloader.default.trustedHosts = trustedHosts
        } else {
            let trustedHosts: Set<String> = [url.host ?? ""]
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
