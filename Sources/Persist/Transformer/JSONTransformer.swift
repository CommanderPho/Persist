import Foundation

public struct JSONTransformer<Input: Codable>: Transformer {

    public typealias Output = Data

    public var encoder: JSONEncoder

    public var decoder: JSONDecoder

    public init(encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
        self.encoder = encoder
        self.decoder = decoder
    }

    public init(coderUserInfo userInfo: [CodingUserInfoKey: Any]) {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        encoder.userInfo = userInfo
        decoder.userInfo = userInfo

        self.init(encoder: encoder, decoder: decoder)
    }

    public func transformValue(_ value: Input) throws -> Data {
        return try encoder.encode(value)
    }

    public func untransformValue(_ data: Data) throws -> Input {
        return try decoder.decode(Input.self, from: data)
    }

}
