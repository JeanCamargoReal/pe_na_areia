//
//  LocalRestaurantLoaderTests.swift
//  RestaurantDomainTests
//
//  Created by Jean Camargo on 22/04/23.
//

/*
 #### Curso primário (caminho feliz):
 OK 1. Execute o comando "Salvar listagem de restaurantes" com os dados acima.
 OK 2. O sistema deleta o cache antigo.
 OK 3. O sistema codifica a lista de restaurantes.
 OK 4. O sistema marca a hora do novo cache.
 OK 5. O sistema salva o cache com novos dados.
 OK 6. O sistema envia uma mensagem de sucesso.

 #### Caso de erro (caminho triste):
 OK 1. O sistema envia uma mensagem de erro.

 #### Caso de erro ao salvar (caminho triste):
 OK 1. O sistema envia uma mensagem de erro.
 */

@testable import RestaurantDomain
import XCTest

final class LocalRestaurantLoaderForSaveCommandTests: XCTestCase {

	func test_save_deletes_old_cache() {
		let (sut, cache) = makeSUT()
		let items = [makeItem()]

		sut.save(items) { _ in }

		XCTAssertEqual(cache.methodsCalled, [.delete])
	}

	func test_save_insert_new_data_on_cache() {
		let currentDate = Date()
		let(sut, cache) = makeSUT(currentDate: currentDate)
		let items = [makeItem()]

		sut.save(items) { _ in }

		cache.completionHandlerForDelete(nil)

		XCTAssertEqual(cache.methodsCalled, [.delete, .save(items: items, timestamp: currentDate)])
	}

	func test_save_fails_after_delete_old_cache() {
		let(sut, cache) = makeSUT()
		let anyError = NSError(domain: "any error", code: -1)

		assert(sut, completion: anyError) {
			cache.completionHandlerForDelete(anyError)
		}
	}

	func test_save_fail_after_insert_new_data_cache() {
		let(sut, cache) = makeSUT()
		let anyError = NSError(domain: "any error", code: -1)

		assert(sut, completion: anyError) {
			cache.completionHandlerForDelete(nil)
			cache.completionHandlerForInsert(anyError)
		}
	}

	func test_save_success_after_insert_new_data_cache() {
		let(sut, cache) = makeSUT()

		assert(sut, completion: nil) {
			cache.completionHandlerForDelete(nil)
			cache.completionHandlerForInsert(nil)
		}
	}

	func test_save_non_insert_after_sut_deallocated() {
		let currentDate = Date()
		let cache = CacheClientSpy()
		var sut: LocalRestaurantLoader? = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })
		let items = [makeItem()]
		var returnedError: Error?

		sut?.save(items) { error in
			returnedError = error
		}
		sut = nil

		cache.completionHandlerForDelete(nil)

		XCTAssertNil(returnedError)
	}

	func test_save_non_completion_after_sut_deallocated() {
		let currentDate = Date()
		let cache = CacheClientSpy()
		var sut: LocalRestaurantLoader? = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })
		let items = [makeItem()]
		var returnedError: Error?

		sut?.save(items) { error in
			returnedError = error
		}

		cache.completionHandlerForDelete(nil)

		sut = nil

		cache.completionHandlerForDelete(nil)

		XCTAssertNil(returnedError)
	}

	private func makeSUT(currentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalRestaurantLoader, cache: CacheClientSpy) {

		let cache = CacheClientSpy()
		let sut = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })

		trackForMemoryLeaks(cache)
		trackForMemoryLeaks(sut)

		return(sut, cache)
	}

	private func makeItem() -> RestaurantItem {
		return RestaurantItem(id: UUID(), name: "name", location: "location", distance: 5.5, ratings: 0, parasols: 0)
	}

	private func assert(_ sut: LocalRestaurantLoader,
						completion error: NSError?,
						when action: () -> Void,
						file: StaticString = #filePath,
						line: UInt = #line) {

		let items = [makeItem()]
		var returnedError: Error?

		sut.save(items) { error in
			returnedError = error
		}

		action()

		XCTAssertEqual(returnedError as? NSError, error)
	}
}
