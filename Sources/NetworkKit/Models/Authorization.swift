enum Authorization {
    case bearer(_ token:String)
    case xiAPIKey(_ apiKey:String)
}
