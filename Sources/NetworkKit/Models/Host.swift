public struct Host {
    let name: String
    let authorization:() async -> Authorization?
    
    public init(
        name: String,
        authorization: @escaping () async -> Authorization?
    ) {
        self.name = name
        self.authorization = authorization
    }
}
