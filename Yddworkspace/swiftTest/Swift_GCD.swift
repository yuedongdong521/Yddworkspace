//
//  Swift_GCD.swift
//  Yddworkspace
//
//  Created by ydd on 2019/7/29.
//  Copyright © 2019 QH. All rights reserved.
//

import Foundation


/// 创建GCD队列
///
/// - Parameters:
///   - name: 队列名称
///   - qos: 队列优先级
///   - attributes: 队列属性，集合类型，[.concurrent, .initiallyInactive], concurrent为并行队列，不设置为穿行队列， initiallyInactive 设置为手动控制运行， 不设置为自动运行
///   - autoreleaseFrequency: 设置管理队列任务内对象的生命周期，  枚举类型,一共三个，
///     1. inherit：继承目标队列的该属性，
///     2. workItem：跟随每个任务的执行周期进行自动创建和释放
///     3. never：不会自动创建 autorelease pool，需要手动管理。一般采用 workItem 行了。如果任务内需要大量重复的创建对象，可以使用 never 类型，来手动创建 aotorelease pool。

///   - targetQueue: 这个参数设置了队列的目标队列，即队列中的任务运行时实际所在的队列。目标队列最终约束了队列的优先级等属性。在程序中手动创建的队列最后都指向了系统自带的主队列或全局并发队列。
/// 那为什么不直接将任务添加到系统队列中，而是自定义队列呢？这样的好处是可以将任务分组管理。如单独阻塞某个队列中的任务，而不是阻塞系统队列中的全部任务。如果阻塞了系统队列，所有指向它的原队列也就被阻塞。
/// 从 Swift 3 开始，对目标队列的设置进行了约束，只有两种情况可以显示的设置目标队列：

/// 在初始化方法中设置目标队列；
/// 在初始化方法中，attributes 设定为 initiallyInactive，在队列调用 activate() 之前，可以指定目标队列。

/// 在其他地方都不能再改变目标队列。

/// - Returns: <#return value description#>
func createGCDQueue(queueName name : String, priorityQos qos : DispatchQoS, attributes : DispatchQueue.Attributes, autoreleaseFrequency : DispatchQueue.AutoreleaseFrequency, targetQueue : DispatchQueue?) -> DispatchQueue {
    
    let queue = DispatchQueue.init(label: name, qos: qos, attributes: attributes, autoreleaseFrequency: autoreleaseFrequency, target: targetQueue)
    
    
    return queue
}

class GCDDemoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    lazy var tableView :UITableView = {
        let tab = UITableView.init(frame: self.view.bounds, style: .plain)
        tab.delegate = self
        tab.dataSource = self
        tab.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        return tab
    }()
    
    let methedList = ["mainQueueAfterResponds", "customQueueAferResponds", "concurrentQueue", "qosQueue", "workItem", "dispatchTimer", "dispatchGroup", "dispatchSemaphore", "dispatchBarrier", "gcdTimer", "active"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0))
        }
        self.tableView.reloadData()
        
        self.userActiveQueue()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return methedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell()
        }
        cell.textLabel?.text = methedList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            mainQueueAfterResponds(aferTime: 2) {
                print("mainQueueAfterResponds : " + "2")
            }
        case 1:
            customQueueAferResponds(aferTime: 2) {
                print("customQueueAferResponds : " + "2")
            }
        case 2:
            concurrentQueue()
        case 3:
            qosQueue()
        case 4:
            workItem()
        case 5:
            dispatchTimer()
        case 6:
            dispatchGroup()
        case 7:
            dispatchSemaphore()
        case 8:
            dispatchBarrier()
        case 9:
            if gcdTimerStart {
                self.cancelTimer()
            } else {
               self.startTimer()
            }
        case 10:
            if #available(iOS 10.0, *) {
                self.activeQueue.activate()
            }
        default:
            break
        }
    }
    
    
    // MARK: 主线程延迟处理
    func mainQueueAfterResponds(aferTime:NSInteger, completed:@escaping ()->Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(aferTime)) {
            completed()
        }
    }
    
    // MARK:自定义队列延迟处理
    func customQueueAferResponds(aferTime:NSInteger, completed:@escaping ()->Void) {
        let queue = DispatchQueue.init(label: "queue-after")
        queue.asyncAfter(deadline: .now() + .seconds(2)) {
            completed()
        }
    }
    
    // MARK: 并发队列
    func concurrentQueue() {
        // 默认是串行队列， concurrent ：并发队列
        let queue = DispatchQueue.init(label: "concurrentQueue", qos: .utility, attributes: .concurrent)
        queue.async {
            for n in 0...100 {
                let name = Thread.current.name ?? "null"
                print("concurrent 1 queue name" + name + String(n))
            }
        }
        queue.async {
            for n in 0...10 {
                let name = Thread.current.name ?? "null"
                print("concurrent 2 queue name" + name + String(n))
            }
        }
    }
    
    // MARK: 多队列优先级处理
    func qosQueue() {
        let defQueue = DispatchQueue.init(label: "qosQueue_def", qos: .default)
        let initatedQueue = DispatchQueue.init(label: "qosQueue_initated", qos: .userInitiated)
        defQueue.async {
            for n in 0...10 {
                let thread = Thread.current.name ?? "nill"
                print("defQueue : " + thread + " n = \(n)")
            }
        }
        initatedQueue.async {
            for n in 0...100 {
                let thread = Thread.current.name ?? "nill"
                print("initatedQueue : " + thread + " n = \(n)")
            }
        }
        
    }
    
    // MARK: DispatchWorkItem 派遣工作项目
    func workItem() {
        var value = 10
        let workItem = DispatchWorkItem {
            value += 5
        }
        let queue = DispatchQueue.global(qos: .utility)
        workItem.notify(queue: DispatchQueue.main) {
            print("workItem value : \(value)")
        }
        queue.async(execute: workItem)
    }
    // MARK: DispatchSourceTimer 定时任务
    func dispatchTimer() {
        let timer = DispatchSource.makeTimerSource()
        // 定时触发
        timer.setEventHandler { // timer作为属性是注意循环引用问题 [weak self] in
            print("timer fired at \(NSDate())")
        }
        // 结束触发
        timer.setCancelHandler {
            print("timer canceled at \(NSDate())")
        }
        
        
        // deadline 表示开始时间
        // leeway   表示能够容忍的误差。
        //repeating 标识间隔时间
        timer.schedule(deadline: .now() + .seconds(1), repeating: 2.0, leeway: .microseconds(10))
        
        print("timer resume at \(NSDate())")
        // 启动定时任务
        timer.resume()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(20)) {
            timer.cancel()
        }
        
        
    }
    
    
    
    // MARK: DispatchGroup
    func dispatchGroup() {
        let group = DispatchGroup()
        
        group.enter()
        request(name: "1") {
            group.leave()
        }
        group.enter()
        request(name: "2") {
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            print("请求结束")
        }
    }
    
    // MARK:DispatchSemaphore 信号量
    func dispatchSemaphore() {
        let semaphore = DispatchSemaphore.init(value: 2)
        let queue = DispatchQueue(label: "dispatchSemaphore", qos: .default, attributes: .concurrent)
        queue.async {
            semaphore.wait()
            self.taskAction(time: 2, des: "DispatchSemaphore 1") {
                semaphore.signal()
            }
        }
        
        queue.async {
            semaphore.wait()
            self.taskAction(time: 3, des: "DispatchSemaphore 2") {
                semaphore.signal()
            }
        }
        // 当前型号量数是2  任务数大于2 需要等之前任务结束 信号量消费完 执行新的任务
        queue.async {
            semaphore.wait()
            self.taskAction(time: 1, des: "DispatchSemaphore 3") {
                semaphore.signal()
            }
        }
    }
    
    // MARK: Dispatch Barrier 任务队列添加栅栏处理
    func dispatchBarrier() {
        let queue = DispatchQueue.init(label: "concurrent_Barrier_queue", attributes: .concurrent)
        queue.async {
            self.taskAction(time: 2, des: "concurrent_Barrier_queue 1") {
                
            }
        }
        queue.async {
            self.taskAction(time: 2, des: "concurrent_Barrier_queue 2") {
                
            }
        }
        
        queue.async(flags: .barrier, execute: {
            print("task barrier 1 begin")
            sleep(3)
            print("task barrier 1 end")
        })
        
        queue.async {
            self.taskAction(time: 2, des: "concurrent_Barrier_queue 3") {
                
            }
        }
        
    }
    
    var gcdTimer : DispatchSourceTimer?
    
    func cretateTimer() -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now(), repeating: 1.0)
        timer.setEventHandler { [weak self] in
            self?.timeAction()
        }
        timer.setCancelHandler { [weak self] in
            self?.timeCancle()
        }
        return timer
    }
    
    var gcdTimerStart = false
    func startTimer() {
        if gcdTimer != nil {
            self.cancelTimer()
        }
        gcdTimerStart = true
        self.gcdTimer = cretateTimer()
        self.gcdTimer?.resume()
    }
    
    func cancelTimer() {
        gcdTimer?.cancel()
        gcdTimer = nil
        gcdTimerStart = false
        count = 0;
    }
    
    var count = 0
    func timeAction() {
        count += 1
        print("触发定时器 count : \(count)")
        if count == 10 {
            self.cancelTimer()
        }
    }
    
    func timeCancle() {
        count = 0
        print("停止定时器")
        gcdTimerStart = false
    }
    
    
    var activeQueue : DispatchQueue = DispatchQueue.init(label: "active_queue")
    
    // MARK: 手动启动队列
    func userActiveQueue() {
        guard #available(iOS 10.0, *) else {
            return
        }
        self.activeQueue = DispatchQueue.init(label: "active_queue", attributes: .initiallyInactive)
        self.activeQueue.async {
            print("手动任务处理 \(Thread.current)")
        }

        print("设置手动任务")

    }
    
    func createQueueTag() {
        if #available(iOS 10.0, *) {
            let testQueue = DispatchQueue.init(label: "test_queue_tag", qos: .default, attributes: [], autoreleaseFrequency: .workItem)
        } else {
            // Fallback on earlier versions
        }
//        DispatchSpecificKey.init()
        
    }
    
}

extension GCDDemoViewController {
    func request(name:NSString, completed:@escaping ()->Void) {
        print("request name prepare : \(name)")
        DispatchQueue.global().async {
            sleep(2)
            DispatchQueue.main.async {
                print("request name completed : \(name)")
                completed()
            }
        }
    }
    
    func taskAction(time:Int, des:NSString, completed:()->Void) {
        print("taskAction pre des : \(des)")
        sleep(UInt32(time))
        print("taskAction completed des : \(des)")
        completed()
    }
    
    
    
}

