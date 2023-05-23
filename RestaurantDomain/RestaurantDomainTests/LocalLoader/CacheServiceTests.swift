//
//  CacheServiceTests.swift
//  RestaurantDomainTests
//
//  Created by Jean Camargo on 23/05/23.
//

/*
#### Inserir
OK - O Cache vazio;
OK - O Cache não vazio substitui o valor anterior;
OK - Erro (se possível simular, ex: permissão);
#### Recuperar
OK - O cache vazio;
OK - O cache não vazio retorna dados;
OK - Erro (se possível para simular, ex: dados inválidos)
#### Apagar
OK - O cache vazio não faz nada (o cache permanece vazio e não falha);
OK - Os dados inseridos são apagadas;
OK - Erro (se possível para simular, ex:, permissão de gravação);
#### Multithread
OK - Os efeitos colaterais (apagar o cache errado, substituir os dados mais recentes, etc)
*/


import XCTest
@testable import RestaurantDomain

final class CacheServiceTests: XCTestCase {

	override func setUp() {
		super.setUp()
		try? FileManager.default.removeItem(at: validManagerURL())
	}

	func test_save_and_returned_last_entered_value() {
		let sut = makeSUT()
		let items = [makeItem(), makeItem()]
		let timestamp = Date()

		insert(sut, items: items, timestamp: timestamp)
		assert(sut, completion: .success(items: items, timestamp: timestamp))
	}

	func test_save_twice_and_returned_last_entered_value() {
		let sut = makeSUT()

		let firstTimeItems = [makeItem(), makeItem()]
		let firstTimeTimestamp = Date()
		insert(sut, items: firstTimeItems, timestamp: firstTimeTimestamp)

		let secondTimeItems = [makeItem(), makeItem()]
		let secondTimeTimestamp = Date()
		insert(sut, items: secondTimeItems, timestamp: secondTimeTimestamp)

		assert(sut, completion: .success(items: secondTimeItems, timestamp: secondTimeTimestamp))
	}

	func test_save_returned_error_when_invalid_manager_url() {
		let managerURL = invalidManagerURL()
		let sut = makeSUT(managerURL: managerURL)

		let firstTimeItems = [makeItem(), makeItem()]
		let firstTimeTimestamp = Date()
		let returnedError = insert(sut, items: firstTimeItems, timestamp: firstTimeTimestamp)

		XCTAssertNotNil(returnedError)
	}

	func test_delete_has_no_effect_to_delete_an_empty_cache() {
		let sut = makeSUT()

		assert(sut, completion: .empty)

		let returnedError = deleteCache(sut)

		XCTAssertNil(returnedError)
	}

	func test_delete_returned_empty_after_insert_new_data_cache() {
		let sut = makeSUT()

		let firstTimeItems = [makeItem(), makeItem()]
		let firstTimeTimestamp = Date()
		insert(sut, items: firstTimeItems, timestamp: firstTimeTimestamp)

		deleteCache(sut)

		assert(sut, completion: .empty)
	}

//	func test_delete_returned_error_when_not_permission() {
//		let managerURL = invalidManagerURL()
//		let sut = makeSUT(managerURL: managerURL)
//
//		let returnedError = deleteCache(sut)
//
//		XCTAssertNotNil(returnedError)
//	}

	func test_load_returned_empty_cache() {
		let sut = makeSUT()

		assert(sut, completion: .empty)
	}

	func test_load_returned_same_empty_cache_for_called_twice() {
		let sut = makeSUT()
		let sameResult: LoadResultState = .empty

		assert(sut, completion: sameResult)
		assert(sut, completion: sameResult)
	}

	func test_load_return_data_after_insert_data() {
		let sut = makeSUT()
		let items = [makeItem(), makeItem()]
		let timestamp = Date()
		insert(sut, items: items, timestamp: timestamp)

		assert(sut, completion: .success(items: items, timestamp: timestamp))
	}

	func test_load_returned_error_when_non_decode_data_cache() {
		let managerURL = validManagerURL()
		let sut = makeSUT(managerURL: managerURL)
		let anyError = NSError(domain: "anyError", code: -1)

		try? "invalidData".write(to: managerURL, atomically: false, encoding: .utf8)

		assert(sut, completion: .failure(anyError))
	}

	func test_taks_with_serial() {
		let sut = makeSUT()
		let items = [makeItem(), makeItem()]
		let timestamp = Date()
		var serialResult = [XCTestExpectation]()

		let task1 = expectation(description: "taks 1")
		sut.save(items, timestamp: timestamp) { _ in
			serialResult.append(task1)
			task1.fulfill()
		}

		let task2 = expectation(description: "taks 2")
		sut.delete { _ in
			serialResult.append(task2)
			task2.fulfill()
		}

		let task3 = expectation(description: "taks 3")
		sut.save(items, timestamp: timestamp) { _ in
			serialResult.append(task3)
			task3.fulfill()
		}

		waitForExpectations(timeout: 3.0)
		XCTAssertEqual(serialResult, [task1, task2, task3])
	}

	private func makeSUT(managerURL: URL? = nil) -> CacheService {
		return CacheService(managerURL: managerURL ?? validManagerURL())
	}

	private func validManagerURL() -> URL {
		let path = type(of: self)
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(path)")
	}

	private func invalidManagerURL() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}

	@discardableResult
	private func insert(_ sut: CacheClient, items: [RestaurantItem], timestamp: Date) -> Error? {
		let exp = expectation(description: "esperando bloco ser completado")
		var resultError: Error?

		sut.save(items, timestamp: timestamp) { error in
			resultError = error
			exp.fulfill()
		}

		wait(for: [exp], timeout: 3.0)

		return resultError
	}

	private func assert(
		_ sut: CacheClient,
		completion result:  LoadResultState,
		file: StaticString = #file,
		line: UInt = #line
	) {
		let exp = expectation(description: "esperando bloco ser completado")

		sut.load { returnedResult in
			switch (result, returnedResult) {
				case (.empty, .empty), (.failure, .failure): break
				case let (.success(items, timestamp), .success(returnedItems, returnedTimestamp)):
					XCTAssertEqual(returnedItems, items, file: file, line: line)
					XCTAssertEqual(returnedTimestamp, timestamp, file: file, line: line)
				default:
					XCTFail("Espero retorno \(result), porem retornou \(returnedResult)", file: file, line: line)
			}

			exp.fulfill()
		}

		wait(for: [exp], timeout: 3.0)
	}

	@discardableResult
	private func deleteCache(_ sut: CacheClient) -> Error? {
		let exp = expectation(description: "esperando bloco ser completado")
		var resultError: Error?

		sut.delete{ error in
			resultError = error
			exp.fulfill()
		}

		wait(for: [exp], timeout: 3.0)

		return resultError
	}
}
