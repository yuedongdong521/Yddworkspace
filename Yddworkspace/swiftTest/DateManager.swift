//
//  File.swift
//  Yddworkspace
//
//  Created by ydd on 2019/9/16.
//  Copyright © 2019 QH. All rights reserved.
//

import Foundation

enum CalendarStyle {
    case gregorian // 公历
    case system // 系统日历
    case cacheSystem // 有缓存的系统日历，缓存第一次取到的系统日历，用户修改设置后这个值不会改变
    case chinese
    
    func calendar() -> Calendar {
        switch self {
        case .gregorian:
            return Calendar.init(identifier: .gregorian)
        case .system:
            return Calendar.autoupdatingCurrent
        case .cacheSystem:
            return Calendar.current
        case .chinese:
            return Calendar.init(identifier: .chinese)
        }
    }
}

enum WeekEnum :Int {
    case unknown = 0
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    func chineseWeek() -> String {
        let per = "星期"
        var suf = ""
        switch self {
        case .sunday:
            suf = "日"
            break
        case .monday:
            suf = "一"
            break
        case .tuesday:
            suf = "二"
            break
        case .wednesday:
            suf = "三"
            break
        case .thursday:
            suf = "四"
            break
        case .friday:
            suf = "五"
            break
        case .saturday:
            suf = "六"
            break
        default:
            return "未知"
        }
        return per + suf
    }
}

class DateManager: NSObject {
//    private override init(){}
//    private init() {}
    class func shareManager() -> DateManager {
        struct Manager {
            static let manager = DateManager()
        }
        return Manager.manager
    }
    
    lazy var formatter:DateFormatter = {
        let matter = DateFormatter.init()
        matter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        return matter
    }()
    
    func creatFormatter(style: CalendarStyle) -> DateFormatter {
        // 设置日历历法格式 （gregorian : 公历）
        let calendar = style.calendar()
        let formatter = DateFormatter.init()
        formatter.calendar = calendar
        return formatter
    }
    
    func getCompends(date:Date) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year,.month,.weekday,.day], from: date)
    }
    
    func getChineseCompends(date:Date) -> DateComponents {
        let calendar = Calendar.init(identifier: .chinese)
        return calendar.dateComponents([.year,.month,.weekday,.day], from: date)
    }
    
    func getCurYearMonth(date:Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .month, in: .year, for: date)
        if range == nil {
            return 0
        }
        return range!.upperBound - range!.lowerBound
    }
    
    /** 获取date月份的天数 */
    func getCurMonthDays(date:Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)
        if range == nil {
            return 0
        }
        return range!.upperBound - range!.lowerBound
    }
    
    /** 获取date是周几 */
    func getWeekForDate(date:Date) -> WeekEnum? {
        let calendar = CalendarStyle.gregorian.calendar()
        let week = calendar.component(.weekday, from: date)
        return WeekEnum.init(rawValue: week)
    }
    
    
    
    /** 获取date月份的第一天date */
    func getMonthFirstDayForDate(date:Date) -> Date? {
        let calender = Calendar.init(identifier: .gregorian)
        var components = calender.dateComponents([.year, .month, .day], from: date)
        if components.day == 1 {
            return date
        }
        components.day = 1
        return calender.date(from: components) ?? nil
    }
    
    func getCurTime() -> Double {
        return Date.init().timeIntervalSince1970
    }
    
    func getDate(time:Double) -> Date {
        return Date.init(timeIntervalSince1970: time)
    }
    
    func dateStr(date:Date) -> String {
        
        return self.formatter.string(from: date)
    }
    
    func stringDate(str:String) -> Date? {
       
        return self.formatter.date(from: str)
    }
    
}
