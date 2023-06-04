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
		let service = RestaurantLoaderSpy()
		let sut = RestaurantListViewController(service: service)

		XCTAssertEqual(service.loadCount, 0)
	}

	func test_viewDidLoad_should_be_called_load_service() {
		let service = RestaurantLoaderSpy()
		let sut = RestaurantListViewController(service: service)

		sut.loadViewIfNeeded()

		XCTAssertEqual(service.loadCount, 1)
	}
}

final class RestaurantLoaderSpy: RestaurantLoader {
	private(set) var loadCount = 0

	func load(completion: @escaping (Result<[RestaurantDomain.RestaurantItem], RestaurantDomain.RestaurantResultError>) -> Void) {
		loadCount += 1
	}
}
