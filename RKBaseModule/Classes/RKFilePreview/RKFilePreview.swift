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
    public var fileUrl: String = ""
    public var thumbUrl: String = ""
    public var size: String?
    public var duration: String?
    public var fileType: RKFileType?
}

public class RKFilePreview {
    
    public static func thumbnailImage(filePath: String, complete: @escaping ThumbnailClosure) {
        guard filePath.count > 0 else { return }
        KingfisherManager.shared.cache.retrieveImage(forKey: filePath) { result in
            switch result {
            case .failure(_):
                fetchThumbnailImage(filePath: filePath, complete: complete)
            case let .success(data):
                if data.cacheType != .none, let image = data.image {
                    complete(image)
                } else {
                    fetchThumbnailImage(filePath: filePath, complete: complete)
                }
            }
        }
    }
    
    private static func fetchThumbnailImage(filePath: String, complete: @escaping ThumbnailClosure) {
        DispatchQueue.global().async {
            RKThumbnailImage.thumbnailImage(filePath) { image in
                if let image = image {
                    KingfisherManager.shared.cache.store(image, forKey: filePath)
                }
                DispatchQueue.main.async {
                    complete(image)
                }
            }
        }
    }

    public static func previewDocFile(filePath: String) {
        guard filePath.count > 0 else { return }
        
        let vc = RKDocumentPreviewVC()
        vc.filePath = filePath
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
