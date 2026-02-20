public struct Host {
    public let name: String
    public let authorization:() async -> Authorization?
    
    public init(
        name: String,
        authorization: @escaping () async -> Authorization?
    ) {
        self.name = name
        self.authorization = authorization
    }
}
