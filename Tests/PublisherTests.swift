/**
*  AsyncCompatibilityKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import XCTest
import Combine
import AsyncCompatibilityKit

final class PublisherTests: XCTestCase {
    func testValuesFromNonThrowingPublisher() async {
        let subject = PassthroughSubject<Int, Never>()

        let valueTask = Task<[Int], Never> {
            var values = [Int]()

            for await value in subject.values {
                values.append(value)
            }

            return values
        }

        Task {
            subject.send(1)
            subject.send(2)
            subject.send(3)
            subject.send(completion: .finished)
        }

        let values = await valueTask.value
        XCTAssertEqual(values, [1, 2, 3])
    }

    func testValuesFromThrowingPublisher() async throws {
        let subject = PassthroughSubject<Int, Error>()

        let valueTask = Task<[Int], Error> {
            var values = [Int]()

            for try await value in subject.values {
                values.append(value)
            }

            return values
        }

        Task {
            subject.send(1)
            subject.send(2)
            subject.send(3)
            subject.send(completion: .finished)
        }

        let values = try await valueTask.value
        XCTAssertEqual(values, [1, 2, 3])
    }

    func testValuesFromThrowingPublisherThatThrowsError() async throws {
        let subject = PassthroughSubject<Int, Error>()
        let error = URLError(.cancelled)
        var values = [Int]()
        let valueHandler = { values.append($0) }

        let valueTask = Task<Void, Error> {
            for try await value in subject.values {
                valueHandler(value)
            }
        }

        Task {
            subject.send(1)
            subject.send(2)
            subject.send(3)
            subject.send(completion: .failure(error))
        }

        do {
            try await valueTask.value
            XCTFail("Expected error to be thrown")
        } catch error as URLError {
            XCTAssertEqual(error.code, .cancelled)
            XCTAssertEqual(values, [1, 2, 3])
        } catch {
            XCTFail("Invalid error thrown: \(error)")
        }
    }
}
