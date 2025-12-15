//
//  URLSessionProtocol.swift
//  GoatJp
//
//  Created by Claude on 12/15/25.
//

import Foundation

/// Protocol to make URLSession injectable for testing
public protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}