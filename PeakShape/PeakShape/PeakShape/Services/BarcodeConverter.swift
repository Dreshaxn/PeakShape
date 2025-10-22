//
//  BarcodeConverter.swift
//  PeakShape
//
//  Created by Dreshawn Young on 7/11/25.
//

import Foundation

public class BarcodeConverter {
    
    public static func convertToGTIN13(_ barcode: String) -> String? {
        let cleanedBarcode = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate input
        guard !cleanedBarcode.isEmpty, cleanedBarcode.allSatisfy({ $0.isNumber }) else {
            return nil
        }
        
        let length = cleanedBarcode.count
        
        switch length {
        case 8:
            return convertEAN8ToGTIN13(cleanedBarcode)
        case 12:
            return convertUPCAToGTIN13(cleanedBarcode)
        case 10:
            return convertUPC10ToGTIN13(cleanedBarcode)
        case 13:
            return isValidGTIN13(cleanedBarcode) ? cleanedBarcode : nil
        case 6:
            return convertUPCEToGTIN13(cleanedBarcode)
        default:
            return nil
        }
    }
    
    private static func convertEAN8ToGTIN13(_ ean8: String) -> String? {
        guard ean8.count == 8, isValidEAN8(ean8) else { return nil }
        
        // EAN-8 to GTIN-13: Add 5 zeros at the beginning
        let gtin13 = "00000" + ean8
        return isValidGTIN13(gtin13) ? gtin13 : nil
    }
    
    private static func convertUPCAToGTIN13(_ upcA: String) -> String? {
        guard upcA.count == 12, isValidUPCA(upcA) else { return nil }
        
        // UPC-A to GTIN-13: Add 0 at the beginning
        let gtin13 = "0" + upcA
        return isValidGTIN13(gtin13) ? gtin13 : nil
    }
    
    private static func convertEAN13ToGTIN13(_ ean13: String) -> String? {
        guard ean13.count == 13, isValidEAN13(ean13) else { return nil }
        
        // EAN-13 is already GTIN-13 format
        return ean13
    }
    
    private static func convertUPC10ToGTIN13(_ upc10: String) -> String? {
        guard upc10.count == 10, isValidUPC10(upc10) else { return nil }
        
        // UPC-10 to GTIN-13: Add "00" prefix to make 12 digits, then calculate check digit
        let upc12 = "00" + upc10
        let checkDigit = calculateGTIN13CheckDigit(upc12)
        let gtin13 = upc12 + String(checkDigit)
        
        return isValidGTIN13(gtin13) ? gtin13 : nil
    }
    
    private static func convertUPCEToGTIN13(_ upcE: String) -> String? {
        guard upcE.count == 6, isValidUPCE(upcE) else { return nil }
        
        // First convert UPC-E to UPC-A, then to GTIN-13
        guard let upcA = convertUPCEToUPCA(upcE) else { return nil }
        return convertUPCAToGTIN13(upcA)
    }
    
    private static func convertUPCEToUPCA(_ upcE: String) -> String? {
        guard upcE.count == 6 else { return nil }
        
        let firstDigit = upcE.first!
        let lastDigit = upcE.last!
        
        // Extract middle 4 digits
        let middleDigits = String(upcE.dropFirst().dropLast())
        
        var upcA: String
        
        switch firstDigit {
        case "0":
            upcA = "0" + middleDigits + "0000" + String(lastDigit)
        case "1":
            upcA = "0" + middleDigits + "1000" + String(lastDigit)
        case "2":
            upcA = "0" + middleDigits + "2000" + String(lastDigit)
        case "3":
            upcA = "0" + middleDigits + "0000" + String(lastDigit)
        case "4":
            upcA = "0" + middleDigits + "0000" + String(lastDigit)
        case "5":
            upcA = "0" + middleDigits + "0000" + String(lastDigit)
        case "6":
            upcA = "0" + middleDigits + "0000" + String(lastDigit)
        case "7":
            upcA = "0" + middleDigits + "0000" + String(lastDigit)
        case "8":
            upcA = "0" + middleDigits + "0000" + String(lastDigit)
        case "9":
            upcA = "0" + middleDigits + "0000" + String(lastDigit)
        default:
            return nil
        }
        
        return isValidUPCA(upcA) ? upcA : nil
    }
    
    // MARK: - Validation Methods
    
    private static func isValidEAN8(_ barcode: String) -> Bool {
        return validateChecksum(barcode)
    }
    
    private static func isValidUPCA(_ barcode: String) -> Bool {
        return validateChecksum(barcode)
    }
    
    private static func isValidEAN13(_ barcode: String) -> Bool {
        return validateChecksum(barcode)
    }
    
    private static func isValidGTIN13(_ barcode: String) -> Bool {
        return validateChecksum(barcode)
    }
    
    private static func isValidUPC10(_ barcode: String) -> Bool {
        // UPC-10 validation: basic format check (10 digits, all numeric)
        return barcode.count == 10 && barcode.allSatisfy { $0.isNumber }
    }
    
    private static func isValidUPCE(_ barcode: String) -> Bool {
        // UPC-E validation is more complex, but for basic validation:
        return barcode.count == 6 && barcode.allSatisfy { $0.isNumber }
    }
    
    private static func calculateGTIN13CheckDigit(_ barcode12: String) -> Int {
        guard barcode12.count == 12, barcode12.allSatisfy({ $0.isNumber }) else { return 0 }
        
        let digits = barcode12.compactMap { $0.wholeNumberValue }
        guard digits.count == 12 else { return 0 }
        
        var sum = 0
        for (index, digit) in digits.enumerated() {
            let multiplier = (index % 2 == 0) ? 1 : 3
            sum += digit * multiplier
        }
        
        return (10 - (sum % 10)) % 10
    }
    
    private static func validateChecksum(_ barcode: String) -> Bool {
        guard barcode.allSatisfy({ $0.isNumber }) else { return false }
        
        let digits = barcode.compactMap { $0.wholeNumberValue }
        guard digits.count == barcode.count else { return false }
        
        var sum = 0
        for (index, digit) in digits.enumerated() {
            let multiplier = (index % 2 == 0) ? 1 : 3
            sum += digit * multiplier
        }
        
        return sum % 10 == 0
    }
    
    // MARK: - Public Utility Methods
    
    public static func detectBarcodeType(_ barcode: String) -> BarcodeType? {
        let cleaned = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard cleaned.allSatisfy({ $0.isNumber }) else { return nil }
        
        switch cleaned.count {
        case 6:
            return .UPC_E
        case 8:
            return .EAN_8
        case 10:
            return .UPC_10
        case 12:
            return .UPC_A
        case 13:
            return .EAN_13
        default:
            return nil
        }
    }
    
    public static func formatBarcode(_ barcode: String) -> String {
        let cleaned = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch cleaned.count {
        case 6:
            return "UPC-E: \(cleaned)"
        case 8:
            return "EAN-8: \(cleaned)"
        case 10:
            return "UPC-10: \(cleaned)"
        case 12:
            return "UPC-A: \(cleaned)"
        case 13:
            return "EAN-13: \(cleaned)"
        default:
            return "Invalid: \(cleaned)"
        }
    }
}

public enum BarcodeType: String, CaseIterable {
    case UPC_E = "UPC-E"
    case EAN_8 = "EAN-8"
    case UPC_10 = "UPC-10"
    case UPC_A = "UPC-A"
    case EAN_13 = "EAN-13"
    case GTIN_13 = "GTIN-13"
}
