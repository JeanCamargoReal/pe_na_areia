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

	func test_load_and_returned_success_with_restaurant_item_list() throws {
		let (sut, client, _) = makeSUT()

		let exp = expectation(description: "esperando retornoa da clousure")

		var returnedResult: RemoteRestaurantLoader.RemoteRestaurantResult?

		sut.load { result in
			returnedResult = result
			exp.fulfill()
		}

		let (model1, json1) = makeItem()
		let (model2, json2) = makeItem()

		let jsonItem = ["items": [json1, json2]]
		let data = try XCTUnwrap(JSONSerialization.data(withJSONObject: jsonItem))

		client.completionWithSuccess(data: data)

		wait(for: [exp], timeout: 1.0)

		XCTAssertEqual(returnedResult, .success([model1, model2]))
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

	private func makeItem(id: UUID = UUID(), name: String = "name", location: String = "location",
						  distance: Float = 5.5, ratings: Int = 4, parasols: Int = 10) -> (model: RestaurantItem,
																						   json: [String: Any]) {
		let model = RestaurantItem(
			id: id,
			name: name,
			location: location,
			distance: distance,
			ratings: ratings,
			parasols: parasols
		)

		let itemJson: [String: Any] = [
			"id": model.id.uuidString,
			"name": model.name,
			"location": model.location,
			"distance": model.distance,
			"ratings": model.ratings,
			"parasols": model.parasols
		]

		return (model, itemJson)
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
