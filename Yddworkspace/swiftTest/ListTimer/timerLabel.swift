//
//  File.swift
//  Yddworkspace
//
//  Created by ydd on 2020/9/11.
//  Copyright © 2020 QH. All rights reserved.
//

import Foundation

class TimerLabel: UIView {
    
    private var _timer : DispatchSourceTimer?
    var endDate : Date? {
        didSet {
            guard let date = self.endDate else {
                resetTimer()
                return
            }
            count = Int(date.timeIntervalSinceNow * 1000)
            updateTimer()
        }
    }
    
    private var count:Int = 0
    
    lazy var label :UILabel = {
        let l = UILabel.init()
        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createUI() {
        self.addSubview(self.label)
        self.label.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets.zero)
        }
        resetTimer()
    }
    
    func startTimer() {
        if _timer != nil {
            cancelTimer()
        }
        
        guard let date = self.endDate else {
            return
        }
        count = Int(date.timeIntervalSinceNow * 1000)
        if count <= 0 {
            return
        }
        _timer = DispatchSource.makeTimerSource()
        _timer?.schedule(deadline: .now(), repeating: 0.1)
        _timer?.setEventHandler(handler: {
            DispatchQueue.main.async {
                self.updateTimer()
            }
        })
        _timer?.setCancelHandler(handler: {
            
        })
        
        _timer?.resume()
    }
    
    func cancelTimer() {
        count = 0
        _timer?.cancel()
        _timer = nil
    }
    
    private let day = 24 * 3600
    
    private func updateTimer() {
        if count < 0 {
            cancelTimer()
        }
        let ss = String(format: "%d", count % 1000 / 100);
        let second = count / 1000;
        let d = String(format: "%d 天", second / day)
        let h = String(format: "%02d", second % day / 3600)
        let m = String(format: "%02d", second % day % 3600 / 60)
        let s = String(format: "%02d", second % day % 3600 % 60)
        
        self.label.text = d + " " + h + ":" + m + ":" + s + " " + ss + "'"
        count -= 100
    }
    
    private func resetTimer() {
        self.label.text = "0天 00:00:00"
    }
    
    deinit {
        print("timerLabel deinit")
    }
    
}

