/**
*  AsyncCompatibilityKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import SwiftUI

@available(iOS, deprecated: 15.0, message: "AsyncCompatibilityKit is only useful when targeting iOS versions earlier than 15")
public extension View {
    /// Attach an async task to this view, which will be performed
    /// when the view first appears, and cancelled if the view
    /// disappears (or is removed from the view hierarchy).
    /// - parameter priority: Any explicit priority that the async
    ///   task should have.
    /// - parameter action: The async action that the task should run.
    func task(
        priority: TaskPriority = .userInitiated,
        _ action: @escaping () async -> Void
    ) -> some View {
        modifier(TaskModifier(
            priority: priority,
            action: action
        ))
    }
}

private struct TaskModifier: ViewModifier {
    var priority: TaskPriority
    var action: () async -> Void

    @State private var task: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .onAppear {
                task = Task(priority: priority) {
                    await action()
                }
            }
            .onDisappear {
                task?.cancel()
                task = nil
            }
    }
}
