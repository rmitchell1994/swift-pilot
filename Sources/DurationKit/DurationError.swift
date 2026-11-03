public enum DurationError: Error, Equatable {
    case negative(Int)
    case tooLarge(Int)
}
