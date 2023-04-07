//
//  RestaurantDomainTests.swift
//  RestaurantDomainTests
//
//  Created by Jean Camargo on 02/04/23.
//

import XCTest
@testable import RestaurantDomain

final class RestaurantDomainTests: XCTestCase {

	func test_initializer_remoteRestauranteLoader_and_validate_urlRequest() {
		let (sut, client, anyURL) = makeSUT()

		sut.load() { _ in }

		XCTAssertEqual(client.urlRequests, [anyURL])
	}

	func test_load_twice() {
		let (sut, client, anyURL) = makeSUT()

		sut.load() { _ in }
		sut.load() { _ in }

		XCTAssertEqual(client.urlRequests, [anyURL, anyURL])
	}

	func test_load_and_returned_error_for_connectivity() {
		let (sut, client, _) = makeSUT()

		let exp = expectation(description: "esperando retornoa da clousure")

		var returnedResult: RemoteRestaurantLoader.RemoteRestaurantResult?

		sut.load { result in
			returnedResult = result
			exp.fulfill()
		}

		client.completionWithError()

		wait(for: [exp], timeout: 1.0)

		XCTAssertEqual(returnedResult, .failure(.connectivity))
	}

	func test_load_and_returned_error_for_invalidData() {
		let (sut, client, _) = makeSUT()

		let exp = expectation(description: "esperando retornoa da clousure")

		var returnedResult: RemoteRestaurantLoader.RemoteRestaurantResult?

		sut.load { result in
			returnedResult = result
			exp.fulfill()
		}

		client.completionWithSuccess()

		wait(for: [exp], timeout: 1.0)

		XCTAssertEqual(returnedResult, .failure(.invalidData))
	}

	func test_load_and_returned_success_with_empty_list() {
		let (sut, client, _) = makeSUT()

		let exp = expectation(description: "esperando retornoa da clousure")

		var returnedResult: RemoteRestaurantLoader.RemoteRestaurantResult?

		sut.load { result in
			returnedResult = result
			exp.fulfill()
		}

		client.completionWithSuccess(data: emptyData())

		wait(for: [exp], timeout: 1.0)

		XCTAssertEqual(returnedResult, .success([]))
	}


	private func makeSUT() -> (sut: RemoteRestaurantLoader, client: NetworkClientSpy, anyURL: URL) {
		let anyURL = URL(string: "https://www.globo.com")!
		let client = NetworkClientSpy()
		let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)

		return (sut, client, anyURL)
	}

	private func emptyData() -> Data {
		return Data("{\"items\": []}".utf8)
	}
}

final class NetworkClientSpy: NetworkClient {
	private(set) var urlRequests: [URL] = []
	private var completionHandler: ((NetworkResult) -> Void)?

	func request(from url: URL, completion: @escaping (NetworkResult) -> Void) {
		urlRequests.append(url)
		completionHandler = completion
	}

	func completionWithError() {
		completionHandler?(.failure(anyError()))
	}

	func completionWithSuccess(statusCode: Int = 200, data: Data = Data()) {
		let response = HTTPURLResponse(url: urlRequests[0], statusCode: statusCode, httpVersion: nil, headerFields: nil)!

		completionHandler?(.success((data, response)))
	}

	private func anyError() -> Error {
		return NSError(domain: "any error", code: -1)
	}
}
