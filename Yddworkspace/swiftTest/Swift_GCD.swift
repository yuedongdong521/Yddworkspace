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

