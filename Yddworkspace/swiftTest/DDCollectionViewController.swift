//
//  DDCollectionViewController.swift
//  Yddworkspace
//
//  Created by ydd on 2019/10/12.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

class DDCollectionViewController: UIViewController {

    lazy var collectionView:UICollectionView = {
        let layout = DDPlainFlowLayout()
        layout.c_flowLayoutDelegate = self
        let collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collection.dataSource = self
        collection.delegate = self
        collection.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        if #available(iOS 11.0, *) {
            collection.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            self.automaticallyAdjustsScrollViewInsets = false
        }
        return collection
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isTranslucent = false
        self.view.addSubview(self.collectionView)
        self.collectionView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets.zero)
        }
        self.collectionView.reloadData()
    }
    
    func showTipsView() {
        let contentView = UIView.init()
        contentView.backgroundColor = UIColor.gray
        self.view.addSubview(contentView)
        contentView.mas_makeConstraints { (make) in
            make?.size.mas_equalTo()(CGSize(width: 300, height: 300))
//            make?.left.mas_equalTo()((self.view.bounds.width - 300) * 0.5)
//            make?.top.mas_equalTo()((self.view.bounds.height - 300) * 0.5)
            make?.center.mas_equalTo()(self.view)
        }
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
       
        contentView.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.3, animations: {
            contentView.transform = CGAffineTransform.identity
        }) { (finish) in
            if finish {
                UIView.animate(withDuration: 0.3, delay: 2, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    contentView.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                }) { (finished) in
                    print("cententView center \(contentView.center)")
                    print("self.view center \(self.view.center)")
                    contentView.removeFromSuperview()
                }
            }
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DDCollectionViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = indexPath.item % 2 == 1 ? UIColor.red : UIColor.green
        return cell
    }
    
}

extension DDCollectionViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.showTipsView()
    }
}


extension DDCollectionViewController : DDFlowLayoutProtocol {
    func dd_collectionColumnNum(collectionView: UICollectionView?, layout: DDPlainFlowLayout, section: NSInteger) -> NSInteger {
        return 2
    }
    
    func dd_collectionCellHeight(collectionView: UICollectionView?, layout: DDPlainFlowLayout, width: CGFloat, indexPath: NSIndexPath) -> CGFloat {
        let arc = CGFloat(arc4random() % 4 + 1) / 4.0
        print("arc  = \(arc)")
        return width * arc
    }
    
    
    
}
