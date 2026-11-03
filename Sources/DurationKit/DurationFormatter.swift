public enum DurationFormatter {
    public static func format(milliseconds: Int) throws -> String {
        guard milliseconds >= 0 else { throw DurationError.negative(milliseconds) }
        guard milliseconds <= Int(Int32.max) else { throw DurationError.tooLarge(milliseconds) }
        return "0s"
    }
}
