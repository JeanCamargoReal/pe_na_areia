//
//  RestaurantDomainTests.swift
//  RestaurantDomainTests
//
//  Created by Jean Camargo on 02/04/23.
//

import XCTest
@testable import RestaurantDomain

final class RemoteRestaurantLoaderTests: XCTestCase {

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

		assert(sut, completion: .failure(.connectivity)) {
			client.completionWithError()
		}
	}

	func test_load_and_returned_error_for_invalidData() {
		let (sut, client, _) = makeSUT()

		assert(sut, completion: .failure(.invalidData)) {
			client.completionWithSuccess()
		}
	}

	func test_load_and_returned_success_with_empty_list() {
		let (sut, client, _) = makeSUT()

		assert(sut, completion: .success([])) {
			client.completionWithSuccess(data: emptyData())
		}
	}

	func test_load_and_returned_success_with_restaurant_item_list() throws {
		let (sut, client, _) = makeSUT()
		let item1 = makeRestaurantItem()
		let item2 = makeRestaurantItem()

		assert(sut, completion: .success([item1.model, item2.model])) {
			let jsonItems = ["items": [item1.json, item2.json]]
			let data = try! JSONSerialization.data(withJSONObject: jsonItems)

			client.completionWithSuccess(data: data)
		}
	}

	func test_load_and_returned_error_for_invalid_statusCode() throws {
		let (sut, client, _) = makeSUT()

		assert(sut, completion: .failure(.invalidData)) {
			let item1 = makeRestaurantItem()
			let item2 = makeRestaurantItem()

			let jsonItems = ["items": [item1.json, item2.json]]
			let data = try! JSONSerialization.data(withJSONObject: jsonItems)

			client.completionWithSuccess(statusCode: 201, data: data)
		}
	}

	func test_load_not_returned_after_sut_deallocated() {
		let anyURL = URL(string: "https://www.globo.com")!
		let client = NetworkClientSpy()
		var sut: RemoteRestaurantLoader? = RemoteRestaurantLoader(url: anyURL, networkClient: client)

		var returnedResult: RestaurantLoader.RestaurantResult?

		sut?.load(completion: { result in
			returnedResult = result
		})

		sut = nil

		client.completionWithSuccess()

		XCTAssertNil(returnedResult)
	}

	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteRestaurantLoader, client: NetworkClientSpy, anyURL: URL) {
		let anyURL = URL(string: "https://www.globo.com")!
		let client = NetworkClientSpy()
		let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)

		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)

		return (sut, client, anyURL)
	}

	private func assert(_ sut: RemoteRestaurantLoader,
						completion result:  RestaurantLoader.RestaurantResult,
						when action: () -> Void,
						file: StaticString = #file,
						line: UInt = #line) {

		let exp = expectation(description: "esperando retorno da clousure")

		var returnedResult: RestaurantLoader.RestaurantResult?

		sut.load { result in
			returnedResult = result
			exp.fulfill()
		}

		action()

		wait(for: [exp], timeout: 1.0)

		XCTAssertEqual(returnedResult, result)
	}

	private func emptyData() -> Data {
		return Data("{\"items\": []}".utf8)
	}

	private func makeRestaurantItem(id: UUID = UUID(), name: String = "name", location: String = "location",
						  distance: Float = 5.5, ratings: Int = 4, parasols: Int = 10) -> (model: RestaurantItem, json: [String: Any]) {
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
