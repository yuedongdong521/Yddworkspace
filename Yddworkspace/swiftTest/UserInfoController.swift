//
//  UserInfoController.swift
//  Yddworkspace
//
//  Created by ydd on 2018/8/3.
//  Copyright © 2018年 QH. All rights reserved.
//

import Foundation

class userInfoModel: NSObject {
  var title : String?
  var content : String?
  override init() {
    super.init()
    title = ""
    content = ""
  }
}

class UserInfoController: UIViewController , UITableViewDelegate, UITableViewDataSource, UserinfoCellDelegate {
  var userInfoArr = Array<userInfoModel>.init()
  lazy var tableView : UITableView = {
    let tableView = UITableView.init(frame: self.view.bounds, style: .plain)
    tableView.backgroundColor = UIColor.clear
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UserInfoTabBaseCell.self, forCellReuseIdentifier: "baseCell")
    tableView.register(UserInfoChooseCell.self, forCellReuseIdentifier: "chooseCell")
    tableView.register(UserInfoTabFootView.self, forHeaderFooterViewReuseIdentifier: "footer")
//    tableView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
    tableView.estimatedRowHeight = 0
    tableView.estimatedSectionFooterHeight = 0
    tableView.estimatedSectionHeaderHeight = 0
    self.view.addSubview(tableView)
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.isTranslucent = false
    self.view.backgroundColor = UIColor.white
    self.view.addSubview(self.tableView)
    createUserInfoData()
  }
  
  func createUserInfoData() {
    let dataArr : Array = [["title":"姓名", "content":"请输入姓名"],
                           ["title":"年龄", "content":"岁"],
                           ["title":"身份证", "content":"请输入身份证"],
                           ["title":"联系方式", "content":"请输入联系方式"],
                           ["title":"信用卡号", "content":"请输入信用卡号"],
                           ["title":"是否已婚", "content":"否"],
                           ["title":"常用地址", "content":"请输入常用地址"],
                           ["title":"详细地址", "content":"请输入详细地址"]]
    for index in 0...dataArr.count - 1 {
       let model = userInfoModel.init()
      model.title = dataArr[index]["title"];
      model.content = dataArr[index]["content"]
      userInfoArr.append(model)
    }
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let model = userInfoArr[indexPath.row]
    if model.title == "是否已婚" {
      let cell : UserInfoChooseCell = tableView.dequeueReusableCell(withIdentifier: "chooseCell") as! UserInfoChooseCell
      cell.titleLabel.text = model.title
      cell.cellDeleagte = self
      return cell
    } else {
      let cell : UserInfoTabBaseCell = tableView.dequeueReusableCell(withIdentifier: "baseCell") as! UserInfoTabBaseCell
      cell.titleLabel.text = model.title
      cell.contentTextView.placeholder = model.content
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footView:UserInfoTabFootView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer") as! UserInfoTabFootView
    footView.delegate = self
    return footView
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 100
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userInfoArr.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  func chooseBtnDeleagte(title: String?) {
    
  }
  
  func commitDelegate() {
    
  }
  
}

