//
//  RestaurantDomainTests.swift
//  RestaurantDomainTests
//
//  Created by Jean Camargo on 02/04/23.
//

import XCTest
@testable import RestaurantDomain

final class RestaurantDomainTests: XCTestCase {

	func test_initializer_remoteRestauranteLoader_and_validate_urlRequest() throws {
		let anyURL =  try XCTUnwrap(URL(string: "https://www.globo.com"))
		let client = NetworkClientSpy()
		let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)

		sut.load() { _ in }

		XCTAssertEqual(client.urlRequests, [anyURL])
	}

	func test_load_twice() throws {
		let anyURL =  try XCTUnwrap(URL(string: "https://www.globo.com"))
		let client = NetworkClientSpy()
		let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)

		sut.load() { _ in }
		sut.load() { _ in }

		XCTAssertEqual(client.urlRequests, [anyURL, anyURL])
	}

	func test_load_and_returned_error_for_connectivity() throws {
		let anyURL =  try XCTUnwrap(URL(string: "https://www.globo.com"))
		let client = NetworkClientSpy()
		let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)
		let exp = expectation(description: "esperando retornoa da clousure")

		var returnedError: Error?

		sut.load { error in
			returnedError = error
			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)

		XCTAssertNotNil(returnedError)
	}
}

final class NetworkClientSpy: NetworkClient {
	private(set) var urlRequests: [URL] = []

	func request(from url: URL, completion: @escaping (Error) -> Void) {
		urlRequests.append(url)
		completion(anyError())
	}

	private func anyError() -> Error {
		return NSError(domain: "any error", code: -1)
	}
}
