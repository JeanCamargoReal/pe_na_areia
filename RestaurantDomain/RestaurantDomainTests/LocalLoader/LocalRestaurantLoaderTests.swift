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

		XCTAssertEqual(cache.methodsCalled, [.delete])
	}

	func test_saveCommand_insert_new_data_on_cache() {
		let currentDate = Date()
		let(sut, cache) = makeSUT()
		let items = [RestaurantItem(id: UUID(), name: "name", location: "location", distance: 5.5, ratings: 0, parasols: 0)]

		sut.save(items) { _ in }

		cache.completionHandlerForDelete(nil)

		XCTAssertEqual(cache.methodsCalled, [.delete, .save(items: items, timestamp: currentDate)])
	}

	private func makeSUT(currentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalRestaurantLoader, cache: CacheClientSpy) {

		let cache = CacheClientSpy()
		let sut = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })

		trackForMemoryLeaks(cache)
		trackForMemoryLeaks(sut)

		return(sut, cache)
	}
}

final class CacheClientSpy: CacheClient {
	enum Methods: Equatable {
		case delete
		case save(items: [RestaurantItem], timestamp: Date)
	}

	private(set) var methodsCalled = [Methods]()

	func save(_ items: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void) {

		methodsCalled.append(.save(items: items, timestamp: timestamp))
	}

	private var completionHandler: ((Error?) -> Void)?

	func delete(completion: @escaping (Error?) -> Void) {
		methodsCalled.append(.delete)
		completionHandler = completion
	}

	func completionHandlerForDelete(_ error: Error?) {
		completionHandler?(error)
	}

}
