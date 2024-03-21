import Foundation

struct MyUser: Hashable, Codable{
    var name: String
    var email: String
    var age: Int
    var weight: Int
    var alcoholStage: Int
    var isConfirmed: String
    var score: Int
}
