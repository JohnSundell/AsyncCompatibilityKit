/**
*  AsyncCompatibilityKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import XCTest
import Combine
import SwiftUI
import AsyncCompatibilityKit

final class ViewTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func testTaskIsStartedWhenViewAppears() {
        var taskWasStarted = false
        let expectation = self.expectation(description: #function)

        let startTask = {
            taskWasStarted = true
            expectation.fulfill()
        }

        let view = Color.clear.task {
            startTask()
        }

        showView(view)

        waitForExpectations(timeout: 1)
        XCTAssertTrue(taskWasStarted)
    }

    func testTaskIsCancelledWhenViewDisappears() {
        class Coordinator: ObservableObject {
            @Published private(set) var showTaskView = true
            @Published private(set) var taskViewDidUpdate = false
            @Published var taskError: Error?

            func updateTaskViewAfterDelay() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.taskViewDidUpdate = true
                }
            }

            func hideTaskViewAfterDelay() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showTaskView = false
                }
            }
        }

        struct TestView: View {
            @ObservedObject var coordinator: Coordinator

            var body: some View {
                if coordinator.showTaskView {
                    Text(coordinator.taskViewDidUpdate ? "Updated" : "Not updated")
                        .task {
                            do {
                                // Make the task wait for 10 seconds, which will
                                // throw an error if the task was cancelled in the
                                // meantime (which is what we're expecting):
                                try await Task.sleep(nanoseconds: 10_000_000_000)
                            } catch {
                                coordinator.taskError = error
                            }
                        }
                        .onAppear {
                            coordinator.updateTaskViewAfterDelay()
                            coordinator.hideTaskViewAfterDelay()
                        }
                }
            }
        }

        let coordinator = Coordinator()
        let view = TestView(coordinator: coordinator)
        showView(view)

        let expectation = self.expectation(description: #function)
        var thrownError: Error?

        coordinator
            .$taskError
            .dropFirst()
            .sink { error in
                thrownError = error
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
        XCTAssertTrue(thrownError is CancellationError)
    }
}

private extension ViewTests {
    func showView<T: View>(_ view: T) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: view)
        window.makeKeyAndVisible()
    }
}
