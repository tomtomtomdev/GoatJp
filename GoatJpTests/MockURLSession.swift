//
//  MockURLSession.swift
//  GoatJpTests
//
//  Created by Claude on 12/15/25.
//

import Foundation
@testable import GoatJp

/// Mock URLSession for testing
final class MockURLSession: URLSessionProtocol {
    private let data: Data?
    private let response: URLResponse?
    private let error: Error?

    init(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.response = response
        self.error = error
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }

        guard let data = data, let response = response else {
            throw URLError(.badServerResponse)
        }

        return (data, response)
    }
}

