#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
import Foundation
@testable import Persist

final class NSUbiquitousKeyValueStoreStorageTests: XCTestCase {

    private let nsUbiquitousKeyValueStoreStorage = NSUbiquitousKeyValueStoreStorage.default

    func testPersistedNSUbiquitousKeyValueStoreAPI() {
        _ = Persisted<Double>(key: "test", storedBy: NSUbiquitousKeyValueStore.default)
        _ = Persisted<Double>(key: "test", storedBy: NSUbiquitousKeyValueStoreStorage.default)

        _ = Persisted<Double>(key: "test", nsUbiquitousKeyValueStore: .default)
        _ = Persisted<Double>(key: "test", nsUbiquitousKeyValueStoreStorage: .default)

        _ = Persisted<Double>(key: "test", storedBy: NSUbiquitousKeyValueStore.default, transformer: MockTransformer())
        _ = Persisted<Double>(key: "test", storedBy: NSUbiquitousKeyValueStoreStorage.default, transformer: MockTransformer())

        _ = Persisted<Double>(key: "test", nsUbiquitousKeyValueStore: .default, transformer: MockTransformer())
        _ = Persisted<Double>(key: "test", nsUbiquitousKeyValueStoreStorage: .default, transformer: MockTransformer())
    }

    func testPersisterNSUbiquitousKeyValueStoreAPI() {
        _ = Persister<Double>(key: "test", storedBy: NSUbiquitousKeyValueStore.default)
        _ = Persister<Double>(key: "test", storedBy: NSUbiquitousKeyValueStoreStorage.default)

        _ = Persister<Double>(key: "test", nsUbiquitousKeyValueStore: .default)
        _ = Persister<Double>(key: "test", nsUbiquitousKeyValueStoreStorage: .default)

        _ = Persister<Double>(key: "test", storedBy: NSUbiquitousKeyValueStore.default, transformer: MockTransformer())
        _ = Persister<Double>(key: "test", storedBy: NSUbiquitousKeyValueStoreStorage.default, transformer: MockTransformer())

        _ = Persister<Double>(key: "test", nsUbiquitousKeyValueStore: .default, transformer: MockTransformer())
        _ = Persister<Double>(key: "test", nsUbiquitousKeyValueStoreStorage: .default, transformer: MockTransformer())
    }

    func testStoredInUbiquitousKeyValueStore() {
        class Foo {
            @StoredInNSUbiquitousKeyValueStore
            var bar: String?

            init(nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage) {
                _bar = StoredInNSUbiquitousKeyValueStore(
                    key: "foo-bar",
                    storedBy: nsUbiquitousKeyValueStoreStorage
                )
            }
        }

        let foo = Foo(nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage)
        foo.bar = "new-value"
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.string(forKey: "foo-bar"), "new-value")
    }

    func testPersisterWithBoolFalse() throws {
        let persister = Persister<Bool>(key: "test", nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage)
        let bool = false

        try persister.persist(bool)
        XCTAssertEqual(try persister.retrieveValue(), bool)
    }

    func testPersisterWithBoolTrue() throws {
        let persister = Persister<Bool>(key: "test", nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage)
        let bool = true

        try persister.persist(bool)
        XCTAssertEqual(try persister.retrieveValue(), bool)
    }

    func testPersisterWithInt64() throws {
        let persister = Persister<Int64>(key: "test", nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage)
        let int64: Int64 = 0

        try persister.persist(int64)
        XCTAssertEqual(try persister.retrieveValue(), int64)
    }

    func testPersisterWithDouble() throws {
        let persister = Persister<Double>(key: "test", nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage)
        let double = 1.23

        try persister.persist(double)
        XCTAssertEqual(try persister.retrieveValue(), double)
    }

    func testPersisterWithArray() throws {
        let persister = Persister<[Int64]>(key: "test", nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage)
        let array: [Int64] = [1, 2, 0, 6]

        try persister.persist(array)
        XCTAssertEqual(try persister.retrieveValue(), array)
    }

    func testPersisterWithDictionary() throws {
        let persister = Persister<[String: [Int64]]>(key: "test", nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage)
        let dictionary: [String: [Int64]] = [
            "foo": [1, 2, 0, 6],
            "bar": [0, 4, 7],
        ]

        try persister.persist(dictionary)
        XCTAssertEqual(try persister.retrieveValue(), dictionary)
    }

    func testRetrieveValueOfDifferentType() {
        let key = "key"
        let actualValue = "test"
        let persister = Persister<Int64>(key: key, nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persister.addUpdateListener() { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch newValue {
            case .failure(PersistenceError.unexpectedValueType(let value, let expected)):
                XCTAssertEqual(value as? String, actualValue)
                XCTAssert(expected == Int64.self)
            default:
                XCTFail()
            }
        }
        _ = cancellable

        nsUbiquitousKeyValueStoreStorage.storeValue(.string(actualValue), key: key)

        XCTAssertThrowsError(try persister.retrieveValue(), "Retrieving a value with a different type should throw") { error in
            switch error {
            case PersistenceError.unexpectedValueType(let value, let expected):
                XCTAssertEqual(value as? String, actualValue)
                XCTAssert(expected == Int64.self)
            default:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 0.1)
    }

    func testStoringStrings() {
        let key = "key"
        let value = "test"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .string(value), "Value passed to update listener should be new value")
        }
        _ = cancellable

        nsUbiquitousKeyValueStoreStorage.storeValue(.string(value), key: key)

        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.string(forKey: key), value, "String should be stored as strings")
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: key), .string(value))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringArray() {
        let key = "key"
        let ubiquitousKeyValueStoreValue = NSUbiquitousKeyValueStoreValue.array([
            .array([.int64(1), .int64(2), .int64(3)]),
            .dictionary([
                "embedded-baz": .double(123.45),
            ]),
            .string("hello world"),
        ])

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, ubiquitousKeyValueStoreValue, "Value passed to update listener should be new value")
        }
        _ = cancellable

        nsUbiquitousKeyValueStoreStorage.storeValue(ubiquitousKeyValueStoreValue, key: key)

        XCTAssertNotNil(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.array(forKey: key), "Arrays should be stored as arrays")
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: key), ubiquitousKeyValueStoreValue)

        waitForExpectations(timeout: 0.1)
    }

    func testStoringDictionary() {
        let key = "key"
        let ubiquitousKeyValueStoreValue = NSUbiquitousKeyValueStoreValue.dictionary([
            "foo": .array([.int64(1), .int64(2), .int64(3)]),
            "bar": .dictionary([
                "embedded-baz": .double(123.45),
            ]),
            "baz": .string("hello world"),
        ])

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, ubiquitousKeyValueStoreValue, "Value passed to update listener should be new value")
        }
        _ = cancellable

        nsUbiquitousKeyValueStoreStorage.storeValue(ubiquitousKeyValueStoreValue, key: key)

        XCTAssertNotNil(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.dictionary(forKey: key), "Dictionaries should be stored as dictionaries")
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: key), ubiquitousKeyValueStoreValue)

        waitForExpectations(timeout: 0.1)
    }

    func testStoringTransformedValues() {
        struct Bar: Codable, Equatable {
            var baz: String
        }

        class Foo {
            @Persisted
            var bar: Bar?

            init(nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage) {
                _bar = Persisted(
                    key: "bar",
                    storedBy: nsUbiquitousKeyValueStoreStorage,
                    transformer: JSONTransformer()
                )
            }
        }

        let bar = Bar(baz: "new-value")
        let foo = Foo(nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage)
        foo.bar = bar
        XCTAssertNotNil(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.data(forKey: "bar"), "Should store transformed value")
        XCTAssertEqual(foo.bar, bar, "Should return untransformed value")
    }

    func testUpdateListenerWithStorageFunction() {
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let cancellable = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: "test") { _ in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = cancellable
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("test"), key: "test")

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerNewValueFromNotification() {
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("initial-value"), key: "test")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let updatedValue = "updated-value"
        let cancellable = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: "test") { update in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(update, .string(updatedValue), "New value should be retrieved and passed to update listeners")
        }
        _ = cancellable

        nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.set(updatedValue, forKey: "test")
        NotificationCenter.default.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore,
            userInfo: [
                NSUbiquitousKeyValueStoreChangedKeysKey: ["test"],
            ]
        )

        waitForExpectations(timeout: 1)
    }

    func testUpdateViaUnderlyingNSUbiquitousKeyValueStoreStorage() {
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("initial-value"), key: "test")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let cancellable = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: "test") { update in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(update, nil, "New value should be retrieved and passed to update listeners")
        }
        _ = cancellable

        nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.removeObject(forKey: "test")
        XCTAssertNil(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: "test"))
        NotificationCenter.default.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore,
            userInfo: [
                NSUbiquitousKeyValueStoreChangedKeysKey: ["test"],
            ]
        )

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerDeletedViaStorage() {
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("initial-value"), key: "test")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let cancellable = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: "test") { update in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(update, nil, "New value should be retrieved and passed to update listeners")
        }
        _ = cancellable

        nsUbiquitousKeyValueStoreStorage.removeValue(for: "test")

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerForDifferentKeyChange() {
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("initial-value"), key: "test")
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("initial-value"), key: "test2")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.isInverted = true
        let cancellable = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: "test") { update in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = cancellable

        nsUbiquitousKeyValueStoreStorage.removeValue(for: "test2")

        waitForExpectations(timeout: 1)
    }

    func testPersisterUpdateListenerUpdateViaPersister() throws {
        let key = "test"
        let setValue = "value"
        let persister = Persister<String>(key: key, storedBy: nsUbiquitousKeyValueStoreStorage)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let updateListenerCancellable = persister.addUpdateListener() { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let value):
                XCTAssertEqual(value, setValue)
            case .failure(let error):
                XCTFail("Should return a success for updated values, not \(error)")
            }
        }
        _ = updateListenerCancellable

        var combineCancellable: Any?
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            let callsPublisherSubscribersExpectation = expectation(description: "Calls publisher subscribers")
            combineCancellable = persister.updatesPublisher.sink { result in
                defer {
                    callsPublisherSubscribersExpectation.fulfill()
                }

                switch result {
                case .success(let value):
                    XCTAssertEqual(value, setValue)
                case .failure:
                    XCTFail("Should return a success for updated values")
                }
            }
            _ = combineCancellable
        }

        try persister.persist(setValue)

        waitForExpectations(timeout: 1)
    }

}
#endif