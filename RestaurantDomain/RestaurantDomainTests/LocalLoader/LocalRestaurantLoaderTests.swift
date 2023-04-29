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
 3. O sistema codifica a lista de restaurantes.
 4. O sistema marca a hora do novo cache.
 5. O sistema salva o cache com novos dados.
 6. O sistema envia uma mensagem de sucesso.

 #### Caso de erro (caminho triste):
 OK 1. O sistema envia uma mensagem de erro.

 #### Caso de erro ao salvar (caminho triste):
 1. O sistema envia uma mensagem de erro.
 */

@testable import RestaurantDomain
import XCTest

final class LocalRestaurantLoaderTests: XCTestCase {

	func test_save_deletes_old_cache() {
		let (sut, cache) = makeSUT()
		let items = [makeItem()]

		sut.save(items) { _ in }

		XCTAssertEqual(cache.methodsCalled, [.delete])
	}

	func test_save_insert_new_data_on_cache() {
		let currentDate = Date()
		let(sut, cache) = makeSUT()
		let items = [makeItem()]

		sut.save(items) { _ in }

		cache.completionHandlerForDelete(nil)

		XCTAssertEqual(cache.methodsCalled, [.delete, .save(items: items, timestamp: currentDate)])
	}

	func test_save_fails_after_delete_old_cache() {
		let(sut, cache) = makeSUT()
		let items = [makeItem()]

		var returnedError: Error?

		sut.save(items) { error in
			returnedError = error
		}

		let anyError = NSError(domain: "any error", code: -1)
		cache.completionHandlerForDelete(anyError)

		XCTAssertEqual(returnedError as? NSError, anyError)
	}

	func test_save_fail_after_insert_new_data_cache() {
		let(sut, cache) = makeSUT()
		let items = [makeItem()]

		var returnedError: Error?

		sut.save(items) { error in
			returnedError = error
		}

		let anyError = NSError(domain: "any error", code: -1)
		cache.completionHandlerForDelete(nil)
		cache.completionHandlerForInsert(anyError)

		XCTAssertEqual(returnedError as? NSError, anyError)
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
}

final class CacheClientSpy: CacheClient {
	enum Methods: Equatable {
		case delete
		case save(items: [RestaurantItem], timestamp: Date)
	}

	private(set) var methodsCalled = [Methods]()

	private var completionHandlerInsert: ((Error?) -> Void)?

	func save(_ items: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
		methodsCalled.append(.save(items: items, timestamp: timestamp))

		completionHandlerInsert = completion
	}

	private var completionHandlerDelete: ((Error?) -> Void)?

	func delete(completion: @escaping (Error?) -> Void) {
		methodsCalled.append(.delete)
		completionHandlerDelete = completion
	}

	func completionHandlerForDelete(_ error: Error?) {
		completionHandlerDelete?(error)
	}

	func completionHandlerForInsert(_ error: Error?) {
		completionHandlerInsert?(error)
	}
}
