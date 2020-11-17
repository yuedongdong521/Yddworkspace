//
//  CalendarViewController.swift
//  Yddworkspace
//
//  Created by ydd on 2019/9/16.
//  Copyright © 2019 QH. All rights reserved.
//

import UIKit

private struct CalendarModel {
    var hasValue = false
    var gComponents:DateComponents = DateComponents.init()
    var zhComponents:DateComponents = DateComponents.init()
    var week = WeekEnum.init(rawValue: 0)
    init(time date:Date?) {
        if date != nil {
            gComponents = DateManager.shareManager().getCompends(date: date!)
            zhComponents = DateManager.shareManager().getChineseCompends(date: date!)
            week = WeekEnum.init(rawValue: (gComponents.weekday!))
            hasValue = true
        }
    }
}

class CalendarHeader: UICollectionReusableView {
    
    lazy var contentLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = NSTextAlignment.left
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.addSubview(self.contentLabel)
        self.contentLabel.frame = self.bounds
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class CalendarCell: UICollectionViewCell {
    
    lazy var contentLabel: UILabel = {
       let label = UILabel.init()
        label.textAlignment = .center
        return label
    }()
    
    lazy var chineseLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    fileprivate func updateCell(model: CalendarModel, isTaday: Bool) {
        if !model.hasValue {
            self.contentLabel.backgroundColor = UIColor.clear
            self.contentLabel.text = ""
            self.chineseLabel.text = ""
            return
        }
        
        self.contentLabel.text = String(model.gComponents.day!)
        if model.zhComponents.day == 1 {
            self.chineseLabel.text = String(model.zhComponents.month!) + "月"
        } else {
            self.chineseLabel.text = String(model.zhComponents.day!)
            
        }
        
        if model.week == WeekEnum.sunday || model.week == WeekEnum.saturday {
            self.contentLabel.textColor = UIColor.red
        } else {
            self.contentLabel.textColor = UIColor.black
        }
        if isTaday {
            self.contentLabel.backgroundColor = UIColor.green
        } else {
            self.contentLabel.backgroundColor = UIColor.clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.contentLabel)
        self.contentLabel.frame = self.bounds
        
        self.addSubview(self.chineseLabel)
        self.chineseLabel .mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(0)
            make?.bottom.mas_equalTo()(0)
            make?.size.mas_equalTo()(CGSize(width: 30, height: 15))
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @objc var year:Int = 0
    
    private lazy var seletedPick :CalendarYearSelectedView = {
        let pick = CalendarYearSelectedView.init(frame: self.view.bounds, year: self.year, selectedBlock: {[weak self] (year) in
            self?.year = year
            self?.reloadCalendar()
        })
        return pick
    }()
    
    private lazy var tadayComp :DateComponents = {
        let comp = DateManager.shareManager().getCompends(date: Date.init())
        return comp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "选择", style: UIBarButtonItem.Style.plain, target: self, action: #selector(rightBarAction))
        
        self.view.backgroundColor = UIColor.white
        self.title = String(year) + "年"
        self.createDate()
        self.view.addSubview(self.collectionView)
        self.creatWeekView()
        self.collectionView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0))
        }
        
        // Do any additional setup after loading the view.
        
        if self.tadayComp.year == self.year {
            DispatchQueue.main.async {
                let curMonth = self.tadayComp.month ?? 0
                self.collectionView .scrollToItem(at: IndexPath.init(item: 0, section: curMonth), at: .centeredVertically, animated: true)
            }
        }
        self.view.addSubview(self.seletedPick)
        self.seletedPick.isHidden = true
    }
    
    func reloadCalendar() {
        self.title = String(year) + "年"
        self.createDate()
        self.collectionView.reloadData()
        if self.tadayComp.year == self.year {
            DispatchQueue.main.async {
                let curMonth = self.tadayComp.month ?? 0
                self.collectionView.scrollToItem(at: IndexPath.init(item: 0, section: curMonth), at: .centeredVertically, animated: true)
            }
        } else {
            self.collectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .centeredVertically, animated: true)
        }
    }
    
    @objc private func rightBarAction() {
        self.seletedPick.isHidden = !self.seletedPick.isHidden
    }
    
    private func creatWeekView() {
        let width = self.view.bounds.width / 7.0
        for index in 0..<7 {
            let label = UILabel.init(frame: CGRect(x: CGFloat(index) * width, y: 0, width: width, height: 40))
            let week = WeekEnum.init(rawValue: index + 1)
            label.text = week?.chineseWeek()
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.textColor = UIColor.red
            self.view.addSubview(label)
        }
    }
    
    private func createDate() {
        let timeStr = "\(year)年1月1日 00:00:00"
        let manager = DateManager.shareManager()
        let date = manager.stringDate(str: timeStr)
        if date == nil {
            return
        }
        self.dateArray.removeAll()
        let months = manager.getCurYearMonth(date: date!)
        var compend = manager.getCompends(date: date!)
        let calendar = Calendar.init(identifier: .gregorian)
        for month in 1...months {
            var daysArr = Array<CalendarModel>()
            compend.month = month
            compend.day = 1
            let fristDate = calendar.date(from: compend)
            if fristDate == nil {
                return
            }
            let monthDay = manager.getCurMonthDays(date: fristDate!)
            let monthCompend = manager.getCompends(date: fristDate!)
            var week = monthCompend.weekday ?? 0
             print("日历 ： week = \(week)")
            week = week % 7
           
            if week > 0 {
                for _ in 1..<week {
                    daysArr.append(CalendarModel.init(time: nil))
                }
            }
            
            for day in 1...monthDay {
                var date: Date?
                if day == 1 {
                    date = fristDate
                } else {
                    compend.day = day
                    date = calendar.date(from: compend)
                    if date == nil {
                        return
                    }
                }
                let model = CalendarModel.init(time: date)
                daysArr.append(model)
            }
            self.dateArray.append(daysArr)
        }
    }
    
    private lazy var dateArray:Array<Array<CalendarModel>> = {
        let arr = Array<Array<CalendarModel>>()
        return arr
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = DDPlainFlowLayout.init()
        flowLayout.c_navHeight = 0
        flowLayout.c_headStyle = .plain
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        let width = self.view.bounds.size.width
        let size = (width - 8 * 10) / 7.0
        flowLayout.itemSize = CGSize(width: size, height: size)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.headerReferenceSize = CGSize(width: width, height: size)
        flowLayout.footerReferenceSize = CGSize.zero
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let collection = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collection.backgroundColor = UIColor.white
        collection.delegate = self
        collection.dataSource = self
        
        collection.register(CalendarCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        collection.register(CalendarHeader.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        if #available(iOS 11.0, *) {
            collection.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        } else {
             self.automaticallyAdjustsScrollViewInsets = false
        }
        
        return collection
    }()
    
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.dateArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dateArray[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarCell
        let model = self.dateArray[indexPath.section][indexPath.item]
        if model.gComponents == self.tadayComp {
            cell.updateCell(model: model, isTaday: true)
        } else {
            cell.updateCell(model: model, isTaday: false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! CalendarHeader
            let model = self.dateArray[indexPath.section].last!
            print("公历 \(model.gComponents.month!) 月份 month = \(model.zhComponents.month!)")
             header.contentLabel.text = "  " + String(model.gComponents.month!) + "月"
            return header
            
        }
        return UICollectionReusableView.init()
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

