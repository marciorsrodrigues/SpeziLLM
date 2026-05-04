//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HTTPTypes
import OpenAPIRuntime


/// `ClientMiddleware` that attaches a fixed dictionary of HTTP headers to every outgoing
/// request. Used to surface app-identification headers (e.g. ``HTTP-Referer`` and
/// ``X-Title``) that OpenAI-compatible gateways like OpenRouter use for analytics
/// and per-app rate-limit tiering.
struct AdditionalHeadersMiddleware: ClientMiddleware {
    let headers: [String: String]

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var modified = request
        for (name, value) in headers {
            if let headerName = HTTPField.Name(name) {
                modified.headerFields[headerName] = value
            }
        }
        return try await next(modified, body, baseURL)
    }
}
