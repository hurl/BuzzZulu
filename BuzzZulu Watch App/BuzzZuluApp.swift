//
//  BuzzZuluApp.swift
//  BuzzZulu Watch App
//
//  Created by chris on 2026-02-02.
//

import SwiftUI

@main
struct BuzzZuluApp: App {
    @StateObject private var alarmManager = AlarmManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alarmManager)
        }
    }
}
