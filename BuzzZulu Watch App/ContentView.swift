import SwiftUI

struct ContentView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @State private var showingAddAlarm = false
    @State private var editingAlarm: ZuluAlarm? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Alarm list
                if alarmManager.alarms.isEmpty {
                    Spacer()
                    Text("No Alarms")
                        .foregroundColor(.red.opacity(0.5))
                    Spacer()
                } else {
                    List {
                        ForEach(alarmManager.alarms) { alarm in
                            AlarmRow(alarm: alarm)
                                .listRowBackground(Color.black)
                                .onTapGesture {
                                    editingAlarm = alarm
                                }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                alarmManager.removeAlarm(alarmManager.alarms[index])
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }

                // Add button at bottom
                Button(action: { showingAddAlarm = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.red)
                }
                .padding(.vertical, 8)
            }
            .background(Color.black)
            .navigationTitle("BuzzZulu")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddAlarm) {
                AddAlarmView()
                    .environmentObject(alarmManager)
            }
            .sheet(item: $editingAlarm) { alarm in
                EditAlarmView(alarm: alarm)
                    .environmentObject(alarmManager)
            }
        }
    }
}

struct AlarmRow: View {
    @EnvironmentObject var alarmManager: AlarmManager
    let alarm: ZuluAlarm

    var body: some View {
        HStack(spacing: 4) {
            Text(String(format: "%02d:%02d", alarm.hour, alarm.minute))
                .font(.system(size: 22, design: .monospaced))
                .foregroundColor(alarm.enabled ? .red : .red.opacity(0.4))
            Text("Z")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(alarm.enabled ? .red.opacity(0.7) : .red.opacity(0.3))
            Spacer()
            Toggle("", isOn: Binding(
                get: { alarm.enabled },
                set: { _ in alarmManager.toggleAlarm(alarm) }
            ))
            .toggleStyle(RedToggleStyle())
        }
    }
}

struct RedToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Capsule()
                .fill(Color.red.opacity(0.3))
                .frame(width: 44, height: 26)
            Circle()
                .fill(Color.red.opacity(0.8))
                .frame(width: 22, height: 22)
                .offset(x: configuration.isOn ? 9 : -9)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                configuration.isOn.toggle()
            }
        }
    }
}

struct AddAlarmView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @Environment(\.dismiss) var dismiss

    @State private var hour: Int = 12
    @State private var minute: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Picker("Hour", selection: $hour) {
                        ForEach(0..<24, id: \.self) { h in
                            Text(String(format: "%02d", h))
                                .foregroundColor(.red)
                                .tag(h)
                        }
                    }
                    .pickerStyle(.wheel)

                    Text(":")
                        .font(.system(size: 32, weight: .medium, design: .monospaced))
                        .foregroundColor(.red)

                    Picker("Minute", selection: $minute) {
                        ForEach(0..<60, id: \.self) { m in
                            Text(String(format: "%02d", m))
                                .foregroundColor(.red)
                                .tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .frame(height: 100)

                Text("Z")
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
                    .foregroundColor(.red.opacity(0.6))
                    .padding(.top, 4)
            }
            .background(Color.black)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.red)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Set") {
                        alarmManager.addAlarm(hour: hour, minute: minute)
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .background(Color.black)
    }
}

struct EditAlarmView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @Environment(\.dismiss) var dismiss
    let alarm: ZuluAlarm

    @State private var hour: Int = 0
    @State private var minute: Int = 0
    @State private var enabled: Bool = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Picker("Hour", selection: $hour) {
                        ForEach(0..<24, id: \.self) { h in
                            Text(String(format: "%02d", h))
                                .foregroundColor(.red)
                                .tag(h)
                        }
                    }
                    .pickerStyle(.wheel)

                    Text(":")
                        .font(.system(size: 32, weight: .medium, design: .monospaced))
                        .foregroundColor(.red)

                    Picker("Minute", selection: $minute) {
                        ForEach(0..<60, id: \.self) { m in
                            Text(String(format: "%02d", m))
                                .foregroundColor(.red)
                                .tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .frame(height: 100)

                Text("Z")
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
                    .foregroundColor(.red.opacity(0.6))
                    .padding(.top, 4)

                Toggle("Enabled", isOn: $enabled)
                    .tint(.red)
                    .padding(.top, 12)

                Button(role: .destructive) {
                    alarmManager.removeAlarm(alarm)
                    dismiss()
                } label: {
                    Text("Delete Alarm")
                        .foregroundColor(.red)
                }
                .padding(.top, 12)
            }
            .padding(.horizontal)
            .background(Color.black)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.red)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        alarmManager.updateAlarm(alarm, hour: hour, minute: minute, enabled: enabled)
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                hour = alarm.hour
                minute = alarm.minute
                enabled = alarm.enabled
            }
        }
        .background(Color.black)
    }
}

#Preview {
    ContentView()
        .environmentObject(AlarmManager())
}
