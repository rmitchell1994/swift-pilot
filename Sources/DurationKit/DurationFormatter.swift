public enum DurationFormatter {
    public static func format(milliseconds: Int) throws -> String {
        guard milliseconds >= 0 else { throw DurationError.negative(milliseconds) }
        guard milliseconds <= Int(Int32.max) else { throw DurationError.tooLarge(milliseconds) }

        let totalSeconds = milliseconds / 1000
        let units: [(value: Int, suffix: String)] = [
            (totalSeconds / 86_400, "d"),
            ((totalSeconds % 86_400) / 3_600, "h"),
            ((totalSeconds % 3_600) / 60, "m"),
            (totalSeconds % 60, "s"),
        ]

        guard let leadingIndex = units.firstIndex(where: { $0.value != 0 }) else { return "0s" }

        var parts = ["\(units[leadingIndex].value)\(units[leadingIndex].suffix)"]
        let nextIndex = leadingIndex + 1
        if nextIndex < units.count, units[nextIndex].value != 0 {
            parts.append("\(units[nextIndex].value)\(units[nextIndex].suffix)")
        }
        return parts.joined(separator: " ")
    }
}
