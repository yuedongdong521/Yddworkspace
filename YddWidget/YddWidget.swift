//
//  YddWidget.swift
//  YddWidget
//
//  Created by ydd on 2020/9/23.
//  Copyright © 2020 QH. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents



struct ImageView :View {
    var body: some View {
        Image("animation_record_img")
//                .scaledToFit()
//                .scaledToFill()
//            .frame(width: geo.size.width, alignment: .center)
            
//            .padding(EdgeInsets.init(top: 20, leading: 20, bottom: 20, trailing: 20))
//            .clipped(antialiased: false)
            .resizable()
            .aspectRatio(1, contentMode: .fill)
    }
    
}

struct YddView : View {
    var body: some View {
        GeometryReader { geo in
            ImageView.init()
                .frame(width: geo.size.width, alignment: .center)
        }
    }
    
}

struct Label : View {
    var size = CGSize.zero
    @State var text = ""
    var body: some View {
        ZStack {
            Color.init(.gray)
                .frame(width: size.width, height: size.height, alignment: .center)
            VStack {
                Text(text)
                Spacer()
            }
        }
    }
}



struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), content: "默认值")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, content: "初始化赋值")
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .month, value: hourOffset, to: currentDate)!
            let time = formatter.string(from: Date.init())
            let entry = SimpleEntry(date: entryDate, configuration: configuration, content: "定时刷新" + "\(time)")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let content: String
    
}

enum YddWidgetType {
    case small
    case medium
    case large
    
    func getEntry() -> YddEntry {
        switch self {
        case .small:
            return YddEntry(date: Date.init(), content: "小部件")
        case .medium:
            return YddEntry(date: Date.init(), content: "中型部件")
        default:
            return YddEntry(date: Date.init(), content: "大部件")
        }
    }
}


struct YddEntry: TimelineEntry {
    let date: Date
    var content: String
}



struct SmallView : View {
    
    @State var name: String = ""
    
    var body: some View {
        ZStack {
            Image.init("0")
                .resizable()
                .aspectRatio(contentMode: .fill)
            VStack {
                HStack(alignment: VerticalAlignment.center, spacing: 20, content: {
                    Text("item1").onTapGesture {
                        self.name = "item1"
                    }
                    Text("item2")
                })
                Spacer().frame(height: 20, alignment: .center)
                HStack(alignment: VerticalAlignment.center, spacing: 20, content: {
                    Text("item3")
                    Text("item4")
                })
            }.widgetURL(URL(string: "ydd://widget.com/test/small/item1" + self.name))
            
        }
    }
}


struct LargeView : View {
   
    var arr = [Text("2")]
    var body: some View {

        
//        Link(destination: URL.init(string: "ydd://widget.com/test/Large")!) {
            Text("Large Widget")
//        }
        
    }
}

struct MediumView : View {
    var entry = SimpleEntry.init(date: Date.init(), configuration: ConfigurationIntent.init(), content: "默认转态")
    
    var body: some View {
        HStack(spacing: 20) {
//            Color(.clear)
//                .frame(width: 0.1, alignment: .leading)
            Image("0")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100, alignment: .center)
                .cornerRadius(50)
                .padding(.leading)
            VStack {
                HStack {
                    Text(entry.content)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
//                Link(destination: URL.init(string: "ydd://widget.com/test/Medium")!) {
//                    HStack {
//                        Text("中位标签, 中间大小的标签")
//                            .multilineTextAlignment(.leading)
//                        Spacer()
//                    }
//                }
                
            }
            Spacer()
            
        }.frame(height: 100, alignment: .center)
        .background(Color.gray)
        
    }
}


struct YddWidgetEntryView : View {
    /// 获取当前widget样式
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var entry: Provider.Entry
    
    var body: some View {
        switch family {
        case WidgetFamily.systemSmall:
            SmallView.init()
        case WidgetFamily.systemMedium:
            MediumView.init(entry: entry)
        case WidgetFamily.systemLarge:
            LargeView.init()
        default:
            SmallView.init()
        }
    }
}

@main
struct YddWidget: Widget {
    let kind: String = "YddWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            YddWidgetEntryView(entry: entry)
                
        }
        .configurationDisplayName("YDD Widget")
        .description("三种Widget测试")
        /// widget样式：
        .supportedFamilies([.systemLarge, .systemSmall, .systemMedium])
        
    }
}

struct YddWidget_Previews: PreviewProvider {
    static var previews: some View {
        YddWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), content: "测试"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
