/**
*  AsyncCompatibilityKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import Foundation

@available(iOS, deprecated: 15.0, message: "AsyncCompatibilityKit is only useful when targeting iOS versions earlier than 15")
public extension URLSession {
    /// Start a data task with a URL using async/await.
    /// - parameter url: The URL to send a request to.
    /// - returns: A tuple containing the binary `Data` that was downloaded,
    ///   as well as a `URLResponse` representing the server's response.
    /// - throws: Any error encountered while performing the data task.
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await data(for: URLRequest(url: url))
    }

    /// Start a data task with a `URLRequest` using async/await.
    /// - parameter request: The `URLRequest` that the data task should perform.
    /// - returns: A tuple containing the binary `Data` that was downloaded,
    ///   as well as a `URLResponse` representing the server's response.
    /// - throws: Any error encountered while performing the data task.
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let sessionTask = URLSessionTaskActor()

        return try await withTaskCancellationHandler {
            Task { await sessionTask.cancel() }
        } operation: {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    await sessionTask.start(dataTask(with: request) { data, response, error in
                        guard let data = data, let response = response else {
                            let error = error ?? URLError(.badServerResponse)
                            continuation.resume(throwing: error)
                            return
                        }

                        continuation.resume(returning: (data, response))
                    })
                }
            }
        }
    }
}

private actor URLSessionTaskActor {
    weak var task: URLSessionTask?

    func start(_ task: URLSessionTask) {
        self.task = task
        task.resume()
    }

    func cancel() {
        task?.cancel()
    }
}
