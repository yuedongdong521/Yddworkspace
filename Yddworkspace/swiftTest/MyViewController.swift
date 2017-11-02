//
//  MyViewController.swift
//  UMSocialDemo
//
//  Created by ispeak on 2017/1/4.
//  Copyright © 2017年 Umeng. All rights reserved.
//

import UIKit


public protocol MyTableViewCellDelegate : NSObjectProtocol {
    
    func deleteActionDelegate(index:NSInteger)
}

class MyTabeleViewCell: UITableViewCell {
    var headImageView = UIImageView()
    var decLabel = UILabel()
    weak open var myDelegate : MyTableViewCellDelegate?;
    var indexRow : NSInteger = 0;
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        headImageView = UIImageView.init(frame: CGRect(x:20, y:10, width:50, height:50))
        headImageView.layer.masksToBounds = true
        headImageView.layer.cornerRadius = headImageView.frame.size.height / 2.0
        headImageView.backgroundColor = UIColor.cyan
        self.contentView.addSubview(headImageView)
        
        decLabel = UILabel.init(frame: CGRect(x:headImageView.frame.size.width + headImageView.frame.origin.x + 10, y:headImageView.frame.origin.y, width:100, height: self.contentView.frame.size.height - 2 * headImageView.frame.origin.y))
        
        let button = UIButton.init(type: UIButtonType.system)
        button.frame = CGRect(x:self.contentView.frame.size.width - 80, y:self.decLabel.frame.origin.y, width:50, height:50)
        button.setTitle("删除", for: UIControlState.normal)
        button.addTarget(self, action: #selector(delegateAction), for: UIControlEvents.touchUpInside)
        button.tag = indexRow
        self.contentView.addSubview(button)
        
        decLabel.font = UIFont.systemFont(ofSize: 12)
        decLabel.textAlignment = NSTextAlignment.left
        self.contentView.addSubview(decLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    func delegateAction(button :UIButton) {
        print("currentRow：%d", button.tag)
        myDelegate?.deleteActionDelegate(index: indexRow)
    }
}

class MyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MyTableViewCellDelegate {
    var array = NSMutableArray()
    var myTableView = UITableView()
    var currentStr = NSString()
    var testArray = NSMutableArray()
    var p_testArray = NSMutableArray()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
        self.view.backgroundColor = UIColor.white
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.alpha = 1.0
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "返回", style: UIBarButtonItemStyle.plain, target: self, action: #selector(navigationBarLeftAction))

        array.addObjects(from: [["ImageView", "0.jpg"], ["Label+Button", "1.jpg"],["View", "0.jpg"]])
    

        print("testArray1 = \(testArray) \n p_testArray1 = \(p_testArray)")
        
        let delay = DispatchTime.now() + .seconds(5) 
        DispatchQueue.main.asyncAfter(deadline: delay) { 
            print("testArray11 = \(self.testArray) \n p_testArray11 = \(self.p_testArray)")
        }
        
        myTableView = UITableView(frame:CGRect(x:0, y:0, width:375, height:667), style: UITableViewStyle.plain)
        myTableView.delegate = self
        myTableView.dataSource = self

        self.view.addSubview(myTableView)
        
        myTableView.register(MyTabeleViewCell.self, forCellReuseIdentifier:"cell")
        myTableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        myTableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
        
        self.view.addObserver(self, forKeyPath: "backgroundColor", options: NSKeyValueObservingOptions.new, context: nil)
        
        let result = self.setStudentInfo(nameStr: "xiaoyou", 1)
        
        let average = self.returnStudentsAverageScores(array: 1, 2)
        
        //单例1.
//        let model1  = MyModule.mymodule
//        let modelStr =  model1.getMyModuleType(tag: 0)
//        print(modelStr)
   
        //单例2.
        let modeule2:MyModule = MyModule.shareMyModelLikeOC()
        let modelValue = modeule2.getMyModuleType(tag: 1)
        let timeStr = modeule2.getCurrentTime()
        print(result,  average, modelValue, timeStr)
    }
    
    func setStudentInfo(nameStr:String, _ num:Int)-> Bool {
        
        return num > 10;
    }
    
    func returnStudentsAverageScores(array:Float...) -> Float {
        var sum: Float = 0.0
        
        for scores:Float in array {
            sum = scores + sum
        }
        
        return sum / Float(array.count);
    }
    
    func navigationBarLeftAction() {
        self.navigationController!.popViewController(animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("ksyPath = \(keyPath) \n object = \(object) \n change = \(change) \n context = \(context)")
    }
    
    deinit {
        self.view.removeObserver(self, forKeyPath: "backgroundColor")
    }
    
    func deleteActionDelegate(index: NSInteger) {
        array.removeObject(at: index)
        
        myTableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: UITableViewRowAnimation.fade)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyTabeleViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MyTabeleViewCell
        cell.myDelegate = self
        let tmpArray = array[indexPath.row] as! Array<String>
        cell.decLabel.text = tmpArray[0]
        cell.headImageView.image = UIImage.init(named:tmpArray[1])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row, array[indexPath.row])
        currentStr = (array[indexPath.row] as! Array<String>)[0] as NSString
        self.view.backgroundColor = UIColor.red
        self.pushViewController(viewStr: (array[indexPath.row] as! Array<String>)[0] as NSString )
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView(reuseIdentifier:"header")
        for var tempView:UIView in headerView.subviews {
            if tempView.isKind(of: UIImageView.self) {
                tempView.removeFromSuperview()
            }
        }
        let imageView = UIImageView(image:UIImage.init(named: "1.jpg"))
        imageView.frame = CGRect(x:0, y:0, width:20, height:20)
        headerView.addSubview(imageView)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footView = UITableViewHeaderFooterView(reuseIdentifier:"footer")
        
        
        return footView;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Header"
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let viewHeight = self.view.bounds.size.height
        let tabHeight = array.count * 50
        if Float(tabHeight) > Float(viewHeight)  {
            return 20
        }
        return 0
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Footer"
    }
    
    
    func pushViewController(viewStr:NSString) {
//        array.addObjects(from: ["ImageView", "Label", "Button"])
        if viewStr.isEqual(to: "ImageView") {
            let imageViewController:ImageViewController = ImageViewController()
            self.navigationController?.pushViewController(imageViewController, animated: true)
        } else if viewStr.isEqual(to: "Label+Button") {
            let mylabelVC = MyLabelViewController()
            mylabelVC.view.backgroundColor = UIColor.white
            self.navigationController?.pushViewController(mylabelVC, animated: true)
        } else if viewStr.isEqual(to: "View") {
            let myViewController = MySwiftViewController()
            myViewController.view.backgroundColor = UIColor.white
            self.navigationController?.pushViewController(myViewController, animated: true)
            
        }
    }
    
    
}
		
