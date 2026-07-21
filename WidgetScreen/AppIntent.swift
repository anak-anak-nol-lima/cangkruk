//
//  AppIntent.swift
//  WidgetScreen
//
//  Created by Stefanie Agahari on 20/07/26.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Status Latihan" }
    static var description: IntentDescription { "Menampilkan status latihan harianmu." }
}
