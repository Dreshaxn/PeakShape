import Foundation
//
//  CalorieCalculatorService.swift
//  PeakShape
//
//  Created by Ryan Gordon on 10/18/25.
//


/**
 Service responsible for calculating user calorie and macronutrient targets.
 
 This service provides the mathematical logic for determining daily calorie needs
 using the **Mifflin–St Jeor** formula for Basal Metabolic Rate (BMR) and standard
 activity multipliers to estimate Total Daily Energy Expenditure (TDEE).
 
 It supports both “Lose X pounds per week” and “Lose X pounds by a target date” goals,
 enforcing healthy and realistic daily calorie deficits with safety floors.
 
 - Note: This service is independent of Firebase and SwiftUI.
   It can be reused in Cloud Functions, ViewModels, or testing environments.
 
 - Important: Always ensure that user weight and height are converted
   to kilograms and centimeters before passing values to this service.
 
 - SeeAlso: `GoalType`, `UserProfile`, `CalorieResult`
 */
public struct CalorieCalculatorService {
    
    // MARK: - Nested Types
    
    /**
     Represents user goal options for calculating calorie targets.
     
     - Parameters:
       - loseByDate: User wants to lose a total amount of weight by a specific target date.
       - losePerWeek: User wants to lose a specific number of pounds per week until their goal is met.
     */
    public enum GoalType {
        case loseByDate(targetDate: Date, poundsToLose: Double)
        case losePerWeek(poundsPerWeek: Double, poundsToLose: Double)
    }
    
    /**
     Represents a user’s physical characteristics and activity level
     used in calorie calculations.
     
     - Parameters:
       - sex: "male" or "female"
       - age: Age in years
       - heightCm: Height in centimeters
       - weightKg: Weight in kilograms
       - activityLevel: Level of daily activity
     */
    public struct UserProfile {
        public var sex: String
        public var age: Int
        public var heightCm: Double
        public var weightKg: Double
        public var activityLevel: ActivityLevel
        
        public init(sex: String, age: Int, heightCm: Double, weightKg: Double, activityLevel: ActivityLevel) {
            self.sex = sex
            self.age = age
            self.heightCm = heightCm
            self.weightKg = weightKg
            self.activityLevel = activityLevel
        }
    }
    
    /**
     Standard activity levels with associated multipliers for TDEE calculation.
     
     - Note: These values are consistent with standard nutrition guidelines.
     */
    public enum ActivityLevel: Double {
        case sedentary = 1.2
        case lightlyActive = 1.375
        case moderatelyActive = 1.55
        case veryActive = 1.725
        case extraActive = 1.9
    }
    
    /**
     Structured result of calorie calculations.
     
     - Parameters:
       - bmr: Basal Metabolic Rate (calories burned at rest)
       - tdee: Total Daily Energy Expenditure (calories burned per day)
       - dailyDeficit: Calorie reduction required per day to meet goal
       - targetCalories: Recommended daily calorie target
       - projectedWeeks: Estimated weeks to reach goal (optional)
       - notes: Guidance or warnings about the plan
     */
    public struct CalorieResult {
        public let bmr: Double
        public let tdee: Double
        public let dailyDeficit: Double
        public let targetCalories: Double
        public let projectedWeeks: Double?
        public let notes: String
    }
    
    // MARK: - Main Calculation
    
    /**
     Calculates a user’s daily calorie target and related nutritional data.
     
     - Parameters:
       - profile: A `UserProfile` containing demographic and physical info.
       - goal: A `GoalType` defining the user’s desired weight loss rate or timeframe.
     
     - Returns: A `CalorieResult` containing detailed calculations and notes.
     
     - Note:
       - Uses Mifflin–St Jeor equation for BMR.
       - Enforces a minimum daily calorie floor (male: 1500, female: 1200).
       - All values are rounded to whole numbers for display.
     
     - SeeAlso: `calculateBMR(for:)`
     */
    public static func calculate(profile: UserProfile, goal: GoalType) -> CalorieResult {
        let bmr = calculateBMR(for: profile)
        let tdee = bmr * profile.activityLevel.rawValue
        
        let kcalPerPound = 3500.0
        var deficitPerDay = 0.0
        var projectedWeeks: Double? = nil
        var notes = ""
        
        switch goal {
        case .losePerWeek(let perWeek, let poundsToLose):
            deficitPerDay = (perWeek * kcalPerPound) / 7.0
            projectedWeeks = poundsToLose / perWeek
            if perWeek > 2 {
                notes = "⚠️ Aggressive plan (>2 lb/week). Consider slower pace for safety."
            } else if perWeek < 0.5 {
                notes = "ℹ️ Conservative plan (<0.5 lb/week). Progress will be gradual."
            }
            
        case .loseByDate(let targetDate, let poundsToLose):
            let days = max(1, Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0)
            deficitPerDay = (poundsToLose * kcalPerPound) / Double(days)
            if deficitPerDay > 1000 {
                notes = "⚠️ High daily deficit (>1000 kcal/day). Extend timeframe for sustainability."
            }
        }
        
        var targetCalories = tdee - deficitPerDay
        let minFloor = (profile.sex.lowercased() == "male") ? 1500.0 : 1200.0
        
        if targetCalories < minFloor {
            targetCalories = minFloor
            notes += " Capped at safe minimum (\(Int(minFloor)) kcal)."
        }
        
        return CalorieResult(
            bmr: round(bmr),
            tdee: round(tdee),
            dailyDeficit: round(deficitPerDay),
            targetCalories: round(targetCalories),
            projectedWeeks: projectedWeeks.map { round($0 * 10) / 10 },
            notes: notes
        )
    }
    
    // MARK: - Helper Methods
    
    /**
     Calculates Basal Metabolic Rate (BMR) using the Mifflin–St Jeor equation.
     
     - Parameter profile: A `UserProfile` with sex, age, height, and weight.
     - Returns: The user’s BMR in kcal/day.
     
     - Note:
       - Males add +5 kcal, females subtract 161 kcal as per the formula.
       - Used internally by `calculate(profile:goal:)`.
     */
    private static func calculateBMR(for profile: UserProfile) -> Double {
        switch profile.sex.lowercased() {
        case "male":
            return 10 * profile.weightKg + 6.25 * profile.heightCm - 5 * Double(profile.age) + 5
        default:
            return 10 * profile.weightKg + 6.25 * profile.heightCm - 5 * Double(profile.age) - 161
        }
    }
}







