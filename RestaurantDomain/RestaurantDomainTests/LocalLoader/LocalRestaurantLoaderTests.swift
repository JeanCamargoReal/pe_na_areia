//
//  LocalRestaurantLoaderTests.swift
//  RestaurantDomainTests
//
//  Created by Jean Camargo on 22/04/23.
//

@testable import RestaurantDomain
import XCTest

final class LocalRestaurantLoaderTests: XCTestCase {

	func test_save_deletes_old_cache() {
		let currentDate = Date()
		let cache = CacheClientSpy()
		let sut = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })
		let items = [RestaurantItem(id: UUID(), name: "name", location: "location", distance: 5.5, ratings: 0, parasols: 0)]

		sut.save(items) { _ in }

		XCTAssertEqual(cache.deleteCount, 1)
	}
}

final class CacheClientSpy: CacheClient {

	func save(_ items: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void) { }

	private(set) var deleteCount = 0

	func delete(completion: @escaping (Error?) -> Void) {
		deleteCount += 1
	}


}
