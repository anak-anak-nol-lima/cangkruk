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
        
        
        /// Integrating App Group – uncomment when final deploy app
        let sharedDefaults = UserDefaults(suiteName: "group.com.ivone.Cangkruk")
        let lastCompletedDate = sharedDefaults?.object(forKey: "lastTrainingCompletedDate") as? Date
        let hasCompletedTraining = lastCompletedDate.map { Calendar.current.isDateInToday($0) } ?? false
        let entry = SimpleEntry(date: Date(), configuration: configuration, hasCompletedTraining: hasCompletedTraining)
        
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

    /// Mode render yang dipilih sistem: `.fullColor` untuk home screen biasa,
    /// `.accented` saat home screen di-tint, `.vibrant` untuk lock screen/StandBy.
    @Environment(\.widgetRenderingMode) private var renderingMode

    /// Artwork lengkap (gradient latar + teks + maskot), sudah di-flatten.
    private var fullColorArtwork: String {
        entry.hasCompletedTraining ? "udahLatihanWidget" : "belumLatihanWidget"
    }

    /// Artwork tanpa latar — hanya teks + maskot dengan alpha.
    /// Di mode tinted/clear sistem membentuk siluet dari alpha channel, jadi
    /// gambar yang latarnya solid akan jadi kotak polos tanpa detail.
    private var maskedArtwork: String {
        entry.hasCompletedTraining ? "udahLatihanFG" : "belumLatihanFG"
    }

    var body: some View {
        Group {
            if renderingMode == .fullColor {
                Image(fullColorArtwork)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(maskedArtwork)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    // ikut warna tint yang dipilih user, bukan diredupkan
                    .widgetAccentable()
            }
        }
        .containerBackground(for: .widget) {
            // di mode tinted/clear latar disediakan sistem, jadi dikosongkan
            Color.clear
        }
        .accessibilityElement()
        .accessibilityLabel(entry.hasCompletedTraining
                            ? Text("Mantap, nanti latihan lagi, yak!")
                            : Text("Ayo, waktunya latihan"))
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
        .contentMarginsDisabled()
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
