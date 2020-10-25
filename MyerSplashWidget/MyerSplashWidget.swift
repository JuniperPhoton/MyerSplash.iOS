//
//  MyerSplashWidget.swift
//  MyerSplashWidget
//
//  Created by JuniperPhoton on 2020/9/26.
//  Copyright © 2020 juniper. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import UIKit
import MyerSplashShared

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), displayUrl: DisplayUrl.Local(named: "today"))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let date = Date()
        let entry = SimpleEntry(date: date, displayUrl: DisplayUrl.Local(named: "today"))
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let date = Date()
        let image = UnsplashImage.create(date)
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 3, to: date)!
        
        ImageIO.cacheImage(image.listUrl) { (image) in
            let entry = SimpleEntry(date: date, displayUrl: DisplayUrl.UIImage(uiImage: image))
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        } onFailure: { (e) in
            let entry = SimpleEntry(date: date, displayUrl: DisplayUrl.Local(named: "today"))
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
    
    typealias Entry = SimpleEntry
}

enum DisplayUrl {
    case Local(named: String)
    case UIImage(uiImage: UIImage)
}

struct SimpleEntry: TimelineEntry {
    private let monthStrings = [
        1: R.strings.month_01,
        2: R.strings.month_02,
        3: R.strings.month_03,
        4: R.strings.month_04,
        5: R.strings.month_05,
        6: R.strings.month_06,
        7: R.strings.month_07,
        8: R.strings.month_08,
        9: R.strings.month_09,
        10: R.strings.month_10,
        11: R.strings.month_11,
        12: R.strings.month_12,
    ]
    
    var date: Date
    let displayUrl: DisplayUrl
    
    func getPrettyMonth() -> String {
        let month = Calendar.current.component(.month, from: date)
        return monthStrings[month]!
    }
}

struct MyerSplashWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var entry: Provider.Entry

    var body: some View {
        let month = entry.getPrettyMonth()
        let day = Calendar.current.component(.day, from: entry.date)

        ZStack(alignment: .bottomTrailing) {
            GeometryReader { geo in
                switch entry.displayUrl {
                case DisplayUrl.Local(let named):
                    Image(named, bundle: Bundle.main)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                case DisplayUrl.UIImage(let uiImage):
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
            }
            
            HStack(alignment: .lastTextBaseline) {
                Text(month)
                    .font(.system(size: 13, weight: .light, design: .default))
                    .foregroundColor(Color.white)
                    .offset(x: 7, y: 0)
                    .shadow(radius: 8)
                Text(String(day))
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(Color.white)
                    .shadow(radius: 8)
            }.offset(x: -10, y: -5)
        }
    }
}

@main
struct MyerSplashWidget: Widget {
    let kind: String = "MyerSplashWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { (entry) in
            MyerSplashWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(LocalizedStringKey(R.strings.widget_title))
        .description(R.strings.widget_desc)
        .supportedFamilies([.systemSmall, .systemLarge, .systemMedium])
    }
}

struct MyerSplashWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyerSplashWidgetEntryView(entry: SimpleEntry(date: Date(), displayUrl: DisplayUrl.Local(named: "today")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
