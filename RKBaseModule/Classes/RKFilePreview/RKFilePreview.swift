//
//  RKFilePreview.swift
//  Pods-RKBaseModule_Example
//
//  Created by 刘爽 on 2023/2/1.
//

import Foundation
import KSYMediaPlayer
import Kingfisher

@objc public enum RKFileType: Int {
    case image = 0
    case video = 1
    case document = 2
}

@objc public class RKFileModel: NSObject {
    public var fileUrl: URL?
    public var thumbUrl: URL?
    public var size: String?
    public var duration: String?
    public var fileType: RKFileType?
}

public class RKFilePreview {

    // 文档预览
    public static func previewDocFile(fileUrl: URL) {
        
        let vc = RKDocumentPreviewVC()
        vc.fileUrl = fileUrl
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 视频 图片预览
    public static func previewFile(fileModels: [RKFileModel], index: Int, push: Bool = false) {
        guard fileModels.count > 0, let vc = UIApplication.topViewController() else { return }
        
        let browser = JXPhotoBrowser()
        browser.numberOfItems = { fileModels.count }
        browser.cellClassAtIndex = { index in
            let m = fileModels[index]
            if m.fileType == .video {
                return RKPreviewVideoCell.self

            } else {
                return RKPreviewImageCell.self
            }
        }
        browser.reloadCellAtIndex = { context in
            let m = fileModels[context.index]
            if m.fileType == .video {
                let browserCell = context.cell as? RKPreviewVideoCell
                browserCell?.reloadVideo(m)
                
            } else {
                let browserCell = context.cell as? RKPreviewImageCell
                browserCell?.reloadImage(m)
            }
        }
        browser.cellWillAppear = { cell, index in
            (cell as? RKPreviewVideoCell)?.autoPlay = true
        }
        browser.cellWillDisappear = { cell, index in
            (cell as? RKPreviewVideoCell)?.autoPlay = false
            (cell as? RKPreviewVideoCell)?.stop()
        }
        browser.pageIndex = index
        
        if push {
            browser.show(method: .push(inNC: vc.navigationController))
            browser.navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            browser.show()
        }
    }
    
    //视频 图片文件大小
    public static func fileSize(fileUrl: URL, complete: @escaping (String)->()) {
        if fileUrl.isFileURL {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: fileUrl, options: .uncachedRead) {
                    DispatchQueue.main.async {
                        complete(String(data.count))
                    }
                }
            }
        } else {
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
    }
    
    // 获取视频文件缩略图
    public static func videoThumbnailImage(fileUrl: URL, complete: @escaping ThumbnailClosure) {
        
        KingfisherManager.shared.cache.retrieveImage(forKey: fileUrl.absoluteString) { result in
            switch result {
            case .failure(_):
                fetchVideoThumbnailImage(fileUrl: fileUrl, complete: complete)
            case let .success(data):
                if data.cacheType != .none, let image = data.image {
                    complete(image, fileUrl)
                } else {
                    fetchVideoThumbnailImage(fileUrl: fileUrl, complete: complete)
                }
            }
        }
    }
    
    private static func fetchVideoThumbnailImage(fileUrl: URL, complete: @escaping ThumbnailClosure) {
        DispatchQueue.global().async {
            RKThumbnailImage.thumbnailImage(fileUrl) { image, path in
                if let image = image {
                    KingfisherManager.shared.cache.store(image, forKey: fileUrl.absoluteString)
                }
                DispatchQueue.main.async {
                    complete(image, fileUrl)
                }
            }
        }
    }
}


public extension UIImageView {
    func rk_videoThumbnailImage(fileUrl: URL?, placeholder: UIImage? = nil, completeClosure: ((UIImage?)-> Void)? = nil) {
        image = placeholder
        guard let fileUrl = fileUrl else {
            completeClosure?(nil)
            return
        }
        tag = fileUrl.hashValue
        RKDownloadManager.trustHost(fileUrl: fileUrl)
        RKFilePreview.videoThumbnailImage(fileUrl: fileUrl) { image, url in
            if self.tag == url.hashValue {
                completeClosure?(image)
                if let image = image { self.image = image }
                
            }
        }
    }
}

public extension UIButton {
    func rk_videoThumbnailImage(fileUrl: URL?, placeholder: UIImage? = nil, completeClosure: ((UIImage?)-> Void)? = nil) {
        setImage(placeholder, for: .normal)
        guard let fileUrl = fileUrl else {
            completeClosure?(nil)
            return
        }
        tag = fileUrl.hashValue
        RKDownloadManager.trustHost(fileUrl: fileUrl)
        RKFilePreview.videoThumbnailImage(fileUrl: fileUrl) { image, url in
            if self.tag == fileUrl.hashValue {
                completeClosure?(image)
                if let image = image { self.setImage(image, for: .normal) }
                
            }
        }
    }
}

public extension UILabel {
    func rk_fileSize(fileUrl: URL, complete: @escaping (String)->()) {
        tag = fileUrl.hashValue
        RKFilePreview.fileSize(fileUrl: fileUrl) { size in
            if self.tag == fileUrl.hashValue {
                complete(size)
            }
        }
    }
}
