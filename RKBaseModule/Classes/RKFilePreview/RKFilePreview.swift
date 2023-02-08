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
    
    public static func thumbnailImage(fileUrl: URL, complete: @escaping ThumbnailClosure) {
        
        KingfisherManager.shared.cache.retrieveImage(forKey: fileUrl.absoluteString) { result in
            switch result {
            case .failure(_):
                fetchThumbnailImage(fileUrl: fileUrl, complete: complete)
            case let .success(data):
                if data.cacheType != .none, let image = data.image {
                    complete(image)
                } else {
                    fetchThumbnailImage(fileUrl: fileUrl, complete: complete)
                }
            }
        }
    }
    
    private static func fetchThumbnailImage(fileUrl: URL, complete: @escaping ThumbnailClosure) {
        DispatchQueue.global().async {
            RKThumbnailImage.thumbnailImage(fileUrl) { image in
                if let image = image {
                    KingfisherManager.shared.cache.store(image, forKey: fileUrl.absoluteString)
                }
                DispatchQueue.main.async {
                    complete(image)
                }
            }
        }
    }

    public static func previewDocFile(fileUrl: URL) {
        
        let vc = RKDocumentPreviewVC()
        vc.fileUrl = fileUrl
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
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
}
