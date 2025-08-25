public struct Host {
    let name: String
    let authorization:() async -> Authorization?
}
