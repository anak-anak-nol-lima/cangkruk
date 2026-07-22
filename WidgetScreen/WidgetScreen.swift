//
//  WidgetScreen.swift
//  WidgetScreen
//
//  Created by Stefanie Agahari on 20/07/26.
//

import WidgetKit
import SwiftUI

/// mengatur jadwal update widget
struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), hasCompletedTraining: false)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, hasCompletedTraining: true)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        let isTrained = false
        
        let entry = SimpleEntry(date: Date(), configuration: configuration, hasCompletedTraining: isTrained)
        entries.append(entry)
        
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
        
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }
}

/// data yang dikirim ke layar
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let hasCompletedTraining: Bool
}

/// UI widget
struct WidgetScreenEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            if entry.hasCompletedTraining {
                VStack {
                    HStack(alignment: .top){
                        Text("MANTAP...\nNANTI\nLATIHAN LAGI\nYAK !")
                            .font(.shakyComicBold(size: 20))
                            .foregroundStyle(Color("Orange"))
                            .accessibilityLabel(Text("Mantap, nanti latihan lagi, yak!"))
                        Spacer()
                    }
                    Spacer()
                }
                VStack {
                    Spacer()
                    
                    Image("LuwakTiduran")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .offset(y: 36)
                        .accessibilityHidden(true)
                }
            } else {
                VStack {
                    HStack(alignment: .top){
                        Text("AYO\nWAKTUNYA\nLATIHAN")
                            .font(.shakyComicBold(size: 20))
                            .foregroundStyle(Color("LightBeige"))
                            .accessibilityLabel(Text("Ayo, waktunya latihan"))
                        Spacer()
                    }
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    Image("LuwakDuduk")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 110)
                        .offset(x: -25, y: 30)
                        .scaleEffect(x: -1, y: 1)
                        .accessibilityHidden(true)
                }
            }
        }
        .containerBackground(entry.hasCompletedTraining ? Color("Beige") : Color("Orange"), for: .widget)
    }
}

struct WidgetScreen: Widget {
    let kind: String = "CangkrukStatusWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            WidgetScreenEntryView(entry: entry)
        }
        .configurationDisplayName("Status Latihan")
        .description("Pantau apakah kamu sudah menyelesaikan modul latihan hari ini.")
        .supportedFamilies([.systemSmall])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var defaultConfig: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
}

#Preview(as: .systemSmall) {
    WidgetScreen()
} timeline: {
    SimpleEntry(date: .now, configuration: .defaultConfig, hasCompletedTraining: false)
    SimpleEntry(date: .now, configuration: .defaultConfig, hasCompletedTraining: true)
}
