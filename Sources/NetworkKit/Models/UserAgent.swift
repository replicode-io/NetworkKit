public struct UserAgent {
    public let appName:String
    public let appVersion:String
    public let deviceModel: String
    public let systemName: String
    public let systemVersion: String
    public let screenScale: Double
    public let formattedScale: String
    
    public var value:String {
        "\(appName)/\(appVersion) (\(deviceModel); \(systemName) \(systemVersion); Scale/\(formattedScale))"
    }
    
    public init(
        appName: String,
        appVersion: String,
        deviceModel: String,
        systemName: String,
        systemVersion: String,
        screenScale: Double,
        formattedScale: String
    ) {
        self.appName = appName
        self.appVersion = appVersion
        self.deviceModel = deviceModel
        self.systemName = systemName
        self.systemVersion = systemVersion
        self.screenScale = screenScale
        self.formattedScale = formattedScale
    }
}
