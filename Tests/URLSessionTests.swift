/**
*  AsyncCompatibilityKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import XCTest
import AsyncCompatibilityKit

final class URLSessionTests: XCTestCase {
    private let session = URLSession.shared
    private let fileContents = "Hello, world!"
    private var fileURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let fileName = "AsyncCompatibilityKitTests-" + UUID().uuidString
        fileURL = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
        try Data(fileContents.utf8).write(to: fileURL)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: fileURL)
    }

    func testDataFromURLWithoutError() async throws {
        let (data, response) = try await session.data(from: fileURL)
        let string = String(decoding: data, as: UTF8.self)

        XCTAssertEqual(string, fileContents)
        XCTAssertEqual(response.url, fileURL)
    }

    func testDataFromURLThatThrowsError() async {
        let invalidURL = fileURL.appendingPathComponent("doesNotExist")

        do {
            _ = try await session.data(from: invalidURL)
            XCTFail("Expected error to be thrown")
        } catch {
            verifyThatError(error, containsURL: invalidURL)
        }
    }

    func testDataWithURLRequestWithoutError() async throws {
        let request = URLRequest(url: fileURL)
        let (data, response) = try await session.data(for: request)
        let string = String(decoding: data, as: UTF8.self)

        XCTAssertEqual(string, fileContents)
        XCTAssertEqual(response.url, fileURL)
    }

    func testDataWithURLRequestThatThrowsError() async {
        let invalidURL = fileURL.appendingPathComponent("doesNotExist")
        let request = URLRequest(url: invalidURL)

        do {
            _ = try await session.data(for: request)
            XCTFail("Expected error to be thrown")
        } catch {
            verifyThatError(error, containsURL: invalidURL)
        }
    }

    func testCancellingTaskCancelsDataTaskBeforeResuming() async throws {
        let task = Task { try await session.data(from: fileURL) }
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected error to be thrown")
        } catch let error as URLError {
            verifyThatError(error, containsURL: fileURL)
            XCTAssertEqual(error.code, .cancelled)
        } catch {
            XCTFail("Invalid error thrown: \(error)")
        }
    }

    func testCancellingParentTaskCancelsDataTask() async throws {
        let task = Task { try await session.data(from: fileURL) }
        Task { task.cancel() }

        do {
            _ = try await task.value
            XCTFail("Expected error to be thrown")
        } catch let error as URLError {
            verifyThatError(error, containsURL: fileURL)
            XCTAssertEqual(error.code, .cancelled)
        } catch {
            XCTFail("Invalid error thrown: \(error)")
        }
    }
}

private extension URLSessionTests {
    func verifyThatError(_ error: Error, containsURL url: URL) {
        // We don't want to make too many assumptions about the
        // errors that URLSession throws, so we simply verify that
        // the thrown error's description contains the URL in question:
        XCTAssertTrue("\(error)".contains(url.absoluteString))
    }
}
