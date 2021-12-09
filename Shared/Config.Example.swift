
struct Config {
    static let StreamLink : String = "https://URL/to/stream/manifest"
    static let Username : String = "Auth0 username".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    static let Password : String = "Auth0 password".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    static let Audience : String = "Auth0 audience".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    static let ClientID : String = "REPLACE ME".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    static let ClientSecret : String = "REPLACE ME".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
}
