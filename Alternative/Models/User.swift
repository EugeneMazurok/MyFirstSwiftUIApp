import Foundation

struct User {
    let id: String = UUID().uuidString
    var name: String
    var email: String
    var age: Int
    var weight: Double
    var alcoholStage: Int
    var job: String

}
