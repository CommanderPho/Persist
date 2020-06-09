#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
public struct StorableInUserDefaultsTransformer<Input: StorableInUserDefaults>: Transformer {

    public func transformValue(_ value: Input) -> UserDefaultsValue {
        return value.asUserDefaultsValue
    }

    public func untransformValue(_ output: UserDefaultsValue) throws -> Input {
        guard let value = output.cast(to: Input.self) else {
            throw PersistenceError.unexpectedValueType(value: output.value, expected: Input.self)
        }

        return value
    }

}
#endif