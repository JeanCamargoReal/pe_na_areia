//
//  RestaurantUITests.swift
//  RestaurantUITests
//
//  Created by Jean Camargo on 02/06/23.
//

import XCTest
import RestaurantDomain
@testable import RestaurantUI

final class RestaurantUITests: XCTestCase {
	func test_init_doe_not_load() {
		let (_, service) = makeSUT()

		XCTAssertEqual(service.loadCount, 0)
	}

	func test_viewDidLoad_should_be_called_load_service() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(service.loadCount, 1)
	}

	func test_load_returned_restaurantItems_data_and_restaurantCollection_does_not_empty() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()

		service.completionSuccess(.success([makeItem()]))

		XCTAssertEqual(service.loadCount, 1)
		XCTAssertEqual(sut.restaurantCollection.count, 1)
	}

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RestaurantListViewController, service: RestaurantLoaderSpy) {

		let service = RestaurantLoaderSpy()
		let sut = RestaurantListViewController(service: service)

		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(service, file: file, line: line)

		return (sut, service)
	}
}

final class RestaurantLoaderSpy: RestaurantLoader {

	private(set) var loadCount = 0
	private var completionLoadHandler: ((RestaurantResult) -> Void)?

	func load(completion: @escaping (RestaurantResult) -> Void) {
		loadCount += 1
		completionLoadHandler = completion
	}

	func completionSuccess(_ result: RestaurantResult) {
		completionLoadHandler?(result)
	}
}
