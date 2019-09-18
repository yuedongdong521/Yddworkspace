//
//  ImageViewController.swift
//  Yddworkspace
//
//  Created by ispeak on 2017/1/5.
//  Copyright © 2017年 QH. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    var myImageView = UIImageView()
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        let widthNum = self.view.bounds.size.width
        _ = self.view.bounds.size.height
        let image = UIImage.init(named: "0.jpg")
        
        myImageView = self.initImageView(frame: CGRect(x:20, y:50, width:widthNum - 40, height:widthNum), image: image!)
        self.view.addSubview(myImageView)
        myImageView.isUserInteractionEnabled = true
        
        myImageView.isHidden = true
        DispatchQueue.global().async {
            print("GCD子线程异步执行")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(2)) {
            self.myImageView.isHidden = false
        }
        
        let tap = UITapGestureRecognizer.init()
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
      
        tap.addTarget(self, action: #selector(imageTensile))
        myImageView.addGestureRecognizer(tap)
        
   
        
        NetWorkRequest().getNetworkRequest(requestUrlStr: "http://img06.tooopen.com/images/20170723/tooopen_sl_217707083674.jpg") { (data, response, error) in
            let imageUrl = URL.init(fileURLWithPath: Bundle.main.path(forResource: "0", ofType: "jpg")!)
            
            do {
                let imageData = try Data.init(contentsOf: imageUrl)
                let image = UIImage.init(data: data ?? imageData)
                if image != nil {
                    DispatchQueue.main.async {
                        self.myImageView.image = image!
                    }
                }
               
            } catch {
                print("imageData is nil")
            }
 
            print(Thread.current)
        }
    }
    
    func initImageView(frame:CGRect, image:UIImage) -> UIImageView {
        let imageView = UIImageView(frame: frame)
        imageView.backgroundColor = UIColor.cyan
        imageView.image = image
        /*
         ScaleToFill: 填充模式，图片不会保持原来的比例
         ScaleAspectFit: 图片保持原来的比例，宽度填充，高度自适应
         ScaleAspectFill： 图片保持原来的比例，高度填充，宽度自适应
         */
        imageView.contentMode = UIViewContentMode.scaleToFill
        
        return imageView;
    }
    
  @objc func imageTensile() {
        let imageView = UIImageView(frame: CGRect(x:20, y:500, width:100, height:100))
        imageView.backgroundColor = UIColor.green
        self.view.addSubview(imageView)
        //通过拉伸来填充
//        imageView.image = UIImage(named:"Session.png")!.resizableImage(withCapInsets: UIEdgeInsetsMake(20, 20, 20, 20))
//        imageView.image = UIImage(named:"Session.png")!.resizableImage(withCapInsets: UIEdgeInsetsMake(20, 20, 20, 20), resizingMode: UIImageResizingMode.stretch)
        
        //通过重复来填充
//        imageView.image = UIImage(named:"Session.png")!.resizableImage(withCapInsets: UIEdgeInsetsMake(20, 20, 20, 20), resizingMode: UIImageResizingMode.tile)
        
        
        //4. 图片动画
        // 创建UIimage数组，数组每个元素为一帧
        let animationImages = NSMutableArray()
//        for var i = 1; i <= 40; i += 1 {
//            let image = UIImage(named: "v\(i).jpg")
//            animationImages.addObject(image!)
//        }
        for index in 1...40 {
            print("index =", index);
        }
    let defaultImage:UIImage! = UIImage.init(named: "0.jpg")
    
    animationImages.addObjects(from: [UIImage(named:"0.jpg") ?? defaultImage!, UIImage(named:"1.jpg") ?? defaultImage!])
        
        let array = animationImages as Array as? [UIImage]
        // 设置animationImages
        imageView.animationImages = array
        // 设置动画时间
        imageView.animationDuration = 9
        // 设置动画循环次数，0为无限循环
        imageView.animationRepeatCount = 0
        // 开启动画
        imageView.startAnimating()
        
    }
    
    
    
    
}
