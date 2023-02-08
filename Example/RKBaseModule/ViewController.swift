//
//  ViewController.swift
//  RKBaseModule
//
//  Created by 刘爽 on 02/01/2023.
//  Copyright (c) 2023 刘爽. All rights reserved.
//

import UIKit
import RKBaseModule

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        RKPrompt.share.promptDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toastAction(_ sender: UIButton) {
        let tag = sender.tag
        if tag == 0 {
//            RKHUD.showSucceed()
            RKHUD.showToast(status: "Toast提示")
        } else if tag == 1 {
            RKHUD.show()
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                RKHUD.dismiss()
            }
        } else if tag == 2 {
            RKFilePreview.previewDocFile(fileUrl: URL(string: "https://ar.rokidcdn.com/saas/im/72fe13541fa1452bbd90e4135531a092/44C95C0B5EB14E748B7DC1DEE897EEF8-%E4%BD%9C%E4%B8%9A%E4%BB%BB%E5%8A%A1%E6%8A%A5%E5%91%8A_%E5%9C%A8%E7%BA%BF%E7%BA%A2%E5%A4%96%E6%B5%8B%E6%B8%A9.pdf")!)
            
        } else if tag == 3 {
            let model1 = RKFileModel()
            model1.fileType = .image
            model1.fileUrl = URL(string: "https://ar.rokidcdn.com/saas/im/72fe13541fa1452bbd90e4135531a092/DAAB47A96DDE4520B5683C55AB07A143-1731420395.jpeg")
            model1.thumbUrl = model1.fileUrl
            
            let model2 = RKFileModel()
            model2.fileType = .image
            model2.fileUrl = URL(string: "https://ar.rokidcdn.com/saas/im/72fe13541fa1452bbd90e4135531a092/EECFCFB28E814E238F6F8745239AC553-684539081.jpeg")
            model2.thumbUrl = model2.fileUrl
            
            let model3 = RKFileModel()
            model3.fileType = .image
            model3.fileUrl = URL(string: "https://ar.rokidcdn.com/saas/im/72fe13541fa1452bbd90e4135531a092/470B37754FB34580ACB88816682BE135-3744029538.jpeg")
            model3.thumbUrl = model3.fileUrl
            
            let model4 = RKFileModel()
            model4.fileType = .image
            model4.fileUrl = URL(string: "https://ar.rokidcdn.com/saas/im/72fe13541fa1452bbd90e4135531a092/EECFCFB28E814E238F6F8745239AC553-684539081.jpeg")
            model4.thumbUrl = model4.fileUrl
           
            let model5 = RKFileModel()
            model5.fileType = .video
            model5.fileUrl = URL(string: "http://vfx.mtime.cn/Video/2019/03/19/mp4/190319222227698228.mp4")
            
            let model6 = RKFileModel()
            model6.fileType = .video
            model6.fileUrl = URL(string: "https://vfx.mtime.cn/Video/2016/11/21/mp4/161121065305521110.mp4")
            
            let model7 = RKFileModel()
            model7.fileType = .video
            model7.fileUrl = URL(string: "https://ar.rokidcdn.com/saas/im/72fe13541fa1452bbd90e4135531a092/AF65B9C6821343FD8B7A214AC4F08404-MKV.mkv")
            
            let model8 = RKFileModel()
            model8.fileType = .video
            model8.fileUrl = URL(string: "https://58.244.22.157:8187/saas-industry/saas/im/72fe13541fa1452bbd90e4135531a092/CAE5E5D7175B4BFCB18589B7C625C941-3000215267.mp4")
            
            let model9 = RKFileModel()
            model9.fileType = .video
            let path = Bundle.main.path(forResource: "1234", ofType: ".mp4")
            model9.fileUrl = URL(fileURLWithPath: path!)
            
            RKFilePreview.previewFile(fileModels: [model1, model2, model3, model4, model8, model7, model6, model5, model9], index: 0)
        }
    }
}

extension ViewController: RKPromptProtocol {
    func showToast(withText: String, inView: UIView?) {
        print("toast提示")
    }
    
    func showLoading(inView: UIView?) {
        print("showLoading")
    }
    
    func hidenLoading(inView: UIView?) {
        print("hidenLoading")
    }
}
