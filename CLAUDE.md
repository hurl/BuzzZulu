## BuzzZulu

WatchOS-only alarm app for UTC (Zulu) time. Designed for pilots, aviation enthusiasts, and anyone who works in UTC. Red-on-black color scheme for night vision preservation.

## Development Setup

* **claude-mem project**: `buzzzulu` - Use `project: "buzzzulu"` for all claude-mem tools.

## Architecture

**Single-target watchOS app** - No iOS companion. Runs independently on Apple Watch.

**Key Files:**
- `BuzzZuluApp.swift` - App entry point, creates AlarmManager as StateObject
- `AlarmManager.swift` - Observable alarm store with UserDefaults persistence and local notification scheduling
- `ContentView.swift` - Main UI: alarm list, add/edit sheets, custom RedToggleStyle

**Data Model:**
```swift
struct ZuluAlarm: Identifiable, Codable {
    let id: UUID
    var hour: Int      // 0-23 UTC
    var minute: Int    // 0-59
    var enabled: Bool
}
```

**Notifications:**
- Uses `UNCalendarNotificationTrigger` with UTC timezone
- Repeats daily at specified Zulu time
- Persisted alarms re-scheduled on app launch

## UI Design

- Red-on-black theme (night vision friendly)
- Custom toggle style matching red color scheme
- Monospaced time display with smaller "Z" suffix
- Bottom-positioned add button (icon only, no label)
- Tap alarm row to edit, swipe to delete

## Reference

`Alarms screenshots/` contains reference images of Apple's native Alarms app for UI comparison.
