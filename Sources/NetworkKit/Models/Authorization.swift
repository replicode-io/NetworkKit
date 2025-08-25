public enum Authorization {
    case bearer(_ token:String)
    case apiKey(_ apiKey:String)
}
