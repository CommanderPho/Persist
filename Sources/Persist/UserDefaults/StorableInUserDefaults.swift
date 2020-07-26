#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

/**
 A protocol that indicates that a value can be stored in `UserDefaults`. This protocol is used to provide
 type safety and should not be conformed to outside of Persist.
 */
public protocol StorableInUserDefaults {
    /// The value of `self` cast to `UserDefaultsValue`.
    var asUserDefaultsValue: UserDefaultsValue { get }
}

extension String: StorableInUserDefaults {
    /// An `UserDefaultsValue.string` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .string(self)
    }
}

extension Data: StorableInUserDefaults {
    /// An `UserDefaultsValue.data` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .data(self)
    }
}

extension URL: StorableInUserDefaults {
    /// An `UserDefaultsValue.url` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .url(self)
    }
}

extension Bool: StorableInUserDefaults {
    /// An `UserDefaultsValue.bool` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .bool(self)
    }
}

extension Int: StorableInUserDefaults {
    /// An `UserDefaultsValue.int` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .int(self)
    }
}

extension Double: StorableInUserDefaults {
    /// An `UserDefaultsValue.double` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .double(self)
    }
}

extension Float: StorableInUserDefaults {
    /// An `UserDefaultsValue.float` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .float(self)
    }
}

extension Array: StorableInUserDefaults where Element: StorableInUserDefaults {
    /// An `UserDefaultsValue.array` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .array(map(\.asUserDefaultsValue))
    }
}

extension Dictionary: StorableInUserDefaults where Key == String, Value: StorableInUserDefaults {
    /// An `UserDefaultsValue.dictionary` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .dictionary(mapValues(\.asUserDefaultsValue))
    }
}
#endif