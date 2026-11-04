public struct CLIResult: Equatable {
    public let stdout: String
    public let stderr: String
    public let exitCode: Int32

    public init(stdout: String, stderr: String, exitCode: Int32) {
        self.stdout = stdout
        self.stderr = stderr
        self.exitCode = exitCode
    }
}

public enum DurationCLI {
    public static func run(arguments: [String]) -> CLIResult {
        guard arguments.count == 1 else {
            return CLIResult(stdout: "", stderr: "usage: duration <milliseconds>", exitCode: 2)
        }
        let argument = arguments[0]
        guard let milliseconds = Int(argument) else {
            return buildFailure("duration: invalid number \(String(reflecting: argument))")
        }
        do {
            let formatted = try DurationFormatter.format(milliseconds: milliseconds)
            return CLIResult(stdout: formatted, stderr: "", exitCode: 0)
        } catch let error as DurationError {
            return buildFailure(toMessage(error, argument: argument))
        } catch {
            return buildFailure("duration: \(String(reflecting: argument)) could not be formatted")
        }
    }

    private static func buildFailure(_ message: String) -> CLIResult {
        CLIResult(stdout: "", stderr: message, exitCode: 1)
    }

    private static func toMessage(_ error: DurationError, argument: String) -> String {
        let quoted = String(reflecting: argument)
        switch error {
        case .negative:
            return "duration: \(quoted) is negative"
        case .tooLarge:
            return "duration: \(quoted) exceeds \(Int32.max) ms"
        }
    }
}
