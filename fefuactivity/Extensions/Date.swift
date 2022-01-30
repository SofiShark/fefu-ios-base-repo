import Foundation

extension Date {
    static func fromString(stringFormat: String) -> Date? {
        
        let stringFormats = ["yyyy/MM/dd HH:mm", "yyyy/MM/dd"]
        let formatter = DateFormatter()
        
        for format in stringFormats {
            formatter.dateFormat = format
            if let date: Date = formatter.date(from: stringFormat) {
                return date
            }
        }
        
        return nil
    }
    
    func shift(unit: Calendar.Component, value: Int) -> Date? {
        return Calendar.current.date(byAdding: unit, value: value, to: self)
    }

    func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        return formatter.localizedString(for: self, relativeTo: date)
    }
    
    func interval(_ date: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.month, .day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        
        return formatter.string(from: self, to: date)!
    }

    func clockDisplay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        return formatter.string(from: self)
    }

    func callendarDate() -> Date {
        let calendar = Calendar.current
        let date = calendar.dateComponents([.year, .month, .day], from: self)

        return calendar.date(from: date) ?? self
    }
    
    func callendarDisplay() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM y"

        return formatter.string(from: self)
    }
}
