struct FoodItem: Identifiable, Codable {
    let id: String
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let sodium: Double
    let potassium: Double
    let vitaminA: Double
    let vitaminC: Double
    let calcium: Double
}
enum FoodItemType: String, CodingKey {
    case id = "_id"
    case name = "product_name"
    case calories
   
}

