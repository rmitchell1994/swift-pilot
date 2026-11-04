import DurationKit
import Foundation

let result = DurationCLI.run(arguments: Array(CommandLine.arguments.dropFirst()))

if !result.stdout.isEmpty {
    FileHandle.standardOutput.write(Data((result.stdout + "\n").utf8))
}
if !result.stderr.isEmpty {
    FileHandle.standardError.write(Data((result.stderr + "\n").utf8))
}
exit(result.exitCode)
