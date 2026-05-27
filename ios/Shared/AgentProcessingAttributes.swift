import Foundation

#if canImport(ActivityKit)
import ActivityKit

@available(iOS 16.1, *)
public struct AgentProcessingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var runState: String
        public var stage: String
        public var detail: String
        public var remainingTasks: Int
        public var updatedAt: Date

        public init(
            runState: String,
            stage: String,
            detail: String,
            remainingTasks: Int,
            updatedAt: Date
        ) {
            self.runState = runState
            self.stage = stage
            self.detail = detail
            self.remainingTasks = remainingTasks
            self.updatedAt = updatedAt
        }
    }

    public var name: String

    public init(name: String) {
        self.name = name
    }
}
#endif
