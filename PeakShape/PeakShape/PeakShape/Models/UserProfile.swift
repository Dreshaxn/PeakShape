import Foundation

// MARK: - Onboarding Data Models

struct UserProfile {
    let name: String
    let sex: Sex
    let age: Int
    let height: Double   // in cm
    let weight: Double   // in kg
    let activityLevel: UserActivityLevel
    let goalWeight: Double   // in kg
    let weightGoal: UserWeightGoal
    let weeklyWeightChange: Double?   // in lbs/week, nil if maintaining weight
}

enum Sex: String, CaseIterable {
    case male, female
    
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}

enum UserActivityLevel: CaseIterable {
    case sedentary
    case light
    case moderate
    case active
    case veryActive
    
    var title: String {
        switch self {
        case .sedentary: return "Sedentary"
        case .light: return "Light Activity"
        case .moderate: return "Moderate Activity"
        case .active: return "Active"
        case .veryActive: return "Very Active"
        }
    }
    
    var description: String {
        switch self {
        case .sedentary: return "Little to no exercise, desk job"
        case .light: return "Light exercise 1-3 days/week"
        case .moderate: return "Moderate exercise 3-5 days/week"
        case .active: return "Heavy exercise 6-7 days/week"
        case .veryActive: return "Very heavy exercise, physical job"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
}

enum UserWeightGoal: CaseIterable {
    case lose
    case maintain
    case gain
    
    var title: String {
        switch self {
        case .lose: return "Lose Weight"
        case .maintain: return "Maintain Weight"
        case .gain: return "Gain Weight"
        }
    }
    
    var description: String {
        switch self {
        case .lose: return "Create a calorie deficit to lose weight"
        case .maintain: return "Keep your current weight stable"
        case .gain: return "Create a calorie surplus to gain weight"
        }
    }
}

// MARK: - Calorie Calculation Extensions

extension UserProfile {
    /// Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
    var bmr: Double {
        let weightInKg = weight
        let heightInCm = height
        let ageInYears = Double(age)
        
        switch sex {
        case .male:
            return (10 * weightInKg) + (6.25 * heightInCm) - (5 * ageInYears) + 5
        case .female:
            return (10 * weightInKg) + (6.25 * heightInCm) - (5 * ageInYears) - 161
        }
    }
    
    /// Calculate TDEE (Total Daily Energy Expenditure)
    var tdee: Double {
        return bmr * activityLevel.multiplier
    }
    
    /// Calculate daily calorie goal based on weight goal
    var dailyCalorieGoal: Double {
        let baseCalories = tdee
        
        switch weightGoal {
        case .lose:
            // 1 lb = ~3500 calories, so 1 lb/week = 500 cal/day deficit
            let weeklyDeficit = weeklyWeightChange ?? 1.0
            let dailyDeficit = weeklyDeficit * 500
            return baseCalories - dailyDeficit
        case .maintain:
            return baseCalories
        case .gain:
            // 1 lb = ~3500 calories, so 1 lb/week = 500 cal/day surplus
            let weeklySurplus = weeklyWeightChange ?? 1.0
            let dailySurplus = weeklySurplus * 500
            return baseCalories + dailySurplus
        }
    }
    
    /// Calculate BMI
    var bmi: Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    /// Get BMI category
    var bmiCategory: String {
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal weight"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }
}

// MARK: - CalorieCalculatorService Integration
extension UserProfile {
    /// Convert to CalorieCalculatorService.UserProfile
    func toCalorieCalculatorProfile() -> CalorieCalculatorService.UserProfile {
        let activityLevel: CalorieCalculatorService.ActivityLevel
        switch self.activityLevel {
        case .sedentary:
            activityLevel = .sedentary
        case .light:
            activityLevel = .lightlyActive
        case .moderate:
            activityLevel = .moderatelyActive
        case .active:
            activityLevel = .veryActive
        case .veryActive:
            activityLevel = .extraActive
        }
        
        return CalorieCalculatorService.UserProfile(
            sex: sex.rawValue,
            age: age,
            heightCm: height,
            weightKg: weight,
            activityLevel: activityLevel
        )
    }
    
    /// Calculate calorie goal using CalorieCalculatorService
    func calculateCalorieGoal() -> CalorieCalculatorService.CalorieResult {
        let profile = toCalorieCalculatorProfile()
        
        let goalType: CalorieCalculatorService.GoalType
        switch weightGoal {
        case .lose:
            let poundsToLose = abs(goalWeight - weight) * 2.20462 // Convert kg to lbs
            let weeklyLoss = weeklyWeightChange ?? 1.0
            goalType = .losePerWeek(poundsPerWeek: weeklyLoss, poundsToLose: poundsToLose)
        case .maintain:
            goalType = .losePerWeek(poundsPerWeek: 0, poundsToLose: 0)
        case .gain:
            let poundsToGain = abs(goalWeight - weight) * 2.20462 // Convert kg to lbs
            let weeklyGain = weeklyWeightChange ?? 1.0
            goalType = .losePerWeek(poundsPerWeek: -weeklyGain, poundsToLose: -poundsToGain)
        }
        
        return CalorieCalculatorService.calculate(profile: profile, goal: goalType)
    }
}
