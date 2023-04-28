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
		let (sut, cache) = makeSUT()
		let items = [RestaurantItem(id: UUID(), name: "name", location: "location", distance: 5.5, ratings: 0, parasols: 0)]

		sut.save(items) { _ in }

		XCTAssertEqual(cache.deleteCount, 1)
	}

	func test_saveCommand_insert_new_data_on_cache() {
		let(sut, cache) = makeSUT()
		let items = [RestaurantItem(id: UUID(), name: "name", location: "location", distance: 5.5, ratings: 0, parasols: 0)]

		sut.save(items) { _ in }

		cache.completionHandlerForDelete(nil)

		XCTAssertEqual(cache.deleteCount, 1)
		XCTAssertEqual(cache.saveCount, 1)
	}

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalRestaurantLoader, cache: CacheClientSpy) {

		let currentDate = Date()
		let cache = CacheClientSpy()
		let sut = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })

		trackForMemoryLeaks(cache)
		trackForMemoryLeaks(sut)

		return(sut, cache)
	}
}

final class CacheClientSpy: CacheClient {

	private(set) var saveCount = 0

	func save(_ items: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
		saveCount += 1
	}

	private(set) var deleteCount = 0
	private var completionHandler: ((Error?) -> Void)?

	func delete(completion: @escaping (Error?) -> Void) {
		deleteCount += 1
		completionHandler = completion
	}

	func completionHandlerForDelete(_ error: Error?) {
		completionHandler?(error)
	}

}
