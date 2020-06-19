#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

// MARK: - Value: StorableInNSUbiquitousKeyValueStore

extension Persisted where Value: StorableInNSUbiquitousKeyValueStore {

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `NSUbiquitousKeyValueStore`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter nsUbiquitousKeyValueStore: The store to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        key: String,
        storedBy nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `NSUbiquitousKeyValueStore`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter nsUbiquitousKeyValueStore: The store to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        key: String,
        nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            storedBy: NSUbiquitousKeyValueStoreStorage(nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore),
            transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Value>(),
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}

extension Persisted {

    // MARK: - Value: StorableInNSUbiquitousKeyValueStore?

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `NSUbiquitousKeyValueStore`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter nsUbiquitousKeyValueStore: The store to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<WrappedValue>(
        key: String,
        storedBy nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInNSUbiquitousKeyValueStore, Value == WrappedValue? {
        self.init(
            key: key,
            nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `NSUbiquitousKeyValueStore`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter nsUbiquitousKeyValueStore: The store to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<WrappedValue>(
        key: String,
        nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInNSUbiquitousKeyValueStore, Value == WrappedValue? {
        self.init(
            key: key,
            storedBy: NSUbiquitousKeyValueStoreStorage(nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore),
            transformer: StorableInNSUbiquitousKeyValueStoreTransformer<WrappedValue>(),
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore

    /**
     Create a new instance that stores the value against the `key`,  storing values in the specified
     `NSUbiquitousKeyValueStore`, defaulting to `defaultValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter nsUbiquitousKeyValueStore: The store to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer>(
        key: String,
        storedBy nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore {
        self.init(
            key: key,
            nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values in the specified
     `NSUbiquitousKeyValueStore`, defaulting to `defaultValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter nsUbiquitousKeyValueStore: The store to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer>(
        key: String,
        nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore {
        let aggregateTransformer = transformer.append(transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: NSUbiquitousKeyValueStoreStorage(nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore),
            transformer: aggregateTransformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == WrappedValue, Transformer.Output: StorableInNSUbiquitousKeyValueStore

    /**
     Create a new instance that stores the value against the `key`,  storing values in the specified
     `NSUbiquitousKeyValueStore`, defaulting to `defaultValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter nsUbiquitousKeyValueStore: The store to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        storedBy nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        transformer: Transformer,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInNSUbiquitousKeyValueStore, Value == WrappedValue? {
        self.init(
            key: key,
            nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values in the specified
     `NSUbiquitousKeyValueStore`, defaulting to `defaultValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter nsUbiquitousKeyValueStore: The store to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        transformer: Transformer,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInNSUbiquitousKeyValueStore, Value == WrappedValue? {
        let aggregateTransformer = transformer.append(transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: NSUbiquitousKeyValueStoreStorage(nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore),
            transformer: aggregateTransformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}
#endif
