//
//  ListTimerViewcontroller.swift
//  Yddworkspace
//
//  Created by ydd on 2020/9/11.
//  Copyright © 2020 QH. All rights reserved.
//

import Foundation

class TimerTableViewCell: UITableViewCell {
    
    lazy var timerLabel: TimerLabel = {
        let label = TimerLabel.init()
        return label
    }()
    
    var date : Date? {
        didSet {
            self.timerLabel.endDate = date
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.addSubview(self.timerLabel)
        self.timerLabel.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets.zero)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ListTimerViewcontroller: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private lazy var dataArr: [Date] = {
        let arr = [Date.init(timeIntervalSinceNow: 1000)]
        return arr
    }()
    
    
    private lazy var tableView: UITableView = {
        let tab = UITableView.init(frame: .zero, style: .plain)
        tab.delegate = self
        tab.dataSource = self
        tab.rowHeight = 60;
        tab.register(TimerTableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        tab.isPagingEnabled = true
        return tab
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0))
        }
        
        for _ in 0..<30 {
            let date = Date.init(timeIntervalSinceNow: TimeInterval(arc4random() % (30 * 24 * 3600)))
//            let date1 = Date.init(timeIntervalSinceNow: 1000)
            
            self.dataArr.append(date)
        }
        
        self.tableView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        for cell in self.tableView.visibleCells {
            guard let timerCell = cell as? TimerTableViewCell else {
                continue
            }
            timerCell.timerLabel.cancelTimer()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TimerTableViewCell else {
            return UITableViewCell.init()
        }
        
        cell.date = self.dataArr[indexPath.row]
        return cell
        
       
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let timerCell = cell as? TimerTableViewCell else {
            return
        }
        timerCell.timerLabel.startTimer()
//        timerCell.timerLabel.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)

        let animate = CABasicAnimation.init(keyPath: "transform.scale");
        animate.fromValue = 0.8;
        animate.toValue = 1.0;
        animate.duration = 0.25;
        timerCell.timerLabel.layer.add(animate, forKey: "displayAnimation")
        
//        UIView.animate(withDuration: 0.25, animations: {
//            timerCell.timerLabel.transform = CGAffineTransform.identity
//        }) { (finish) in
//            timerCell.timerLabel.transform = CGAffineTransform.identity
//        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
        guard let timerCell = cell as? TimerTableViewCell else {
            return
        }
        timerCell.timerLabel.cancelTimer()
        
//        UIView.animate(withDuration: 0.25, animations: {
//            timerCell.timerLabel.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
//        }) { (finish) in
//
//        }
        
        let animate = CABasicAnimation.init(keyPath: "transform.scale");
        animate.fromValue = 1;
        animate.toValue = 0.8;
        animate.duration = 0.25;
        timerCell.timerLabel.layer.add(animate, forKey: "displayAnimation")
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    
    func step(_ n: Int) -> Int {
        var total = n > 0 ? 1 : 0;
        var count = n
        while count > 0 {
            total *= 2
            count -= 1
        }
        return total
        
    }
    
    deinit {
        print("ListTimer deinit")
    }
    
}
