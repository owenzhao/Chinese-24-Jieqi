//
//  Jieqi.swift
//  Jieqi
//
//  Created by zhaoxin on 2021/12/18.
//

import Foundation

public struct Jieqi {
    public static let cal = Calendar(identifier: .gregorian)
    
    public init() {}
    
    private func getjq(yyyy:Int, mm:Int, dd:Int) -> Name? {
        let mm = mm - 1
        
        let sTermInfo = [
            0,21208,42467,63836,85337,107014,128867,150921,173149,195551,218072,240693,263343,285989,308563,331033,353350,375494,397447,419210,440795,462224,483532,504758
        ]
        
        let solarTerm = Name.allCases
        
        var cps = DateComponents()
        cps.year = 1900
        cps.month = 1
        cps.day = 6
        cps.hour = 2
        cps.minute = 5
        var tmp1 = Date(timeInterval: (31556925974.7 * Double(yyyy - 1900) + Double(sTermInfo[mm * 2 + 1] * 60000)) / 1000,
                        since: Jieqi.cal.date(from: cps)!)
        var tmp2 = tmp1
        var day2 = Jieqi.cal.component(.day, from: tmp2)
        var solarTerms:Name? = nil
        
        if day2 == dd {
            solarTerms = solarTerm[mm * 2 + 1]
        }
        
        tmp1 = Date(timeInterval: (31556925974.7 * Double(yyyy - 1900) + Double(sTermInfo[mm * 2] * 60000)) / 1000,
                    since: Jieqi.cal.date(from: cps)!)
        tmp2 = tmp1
        day2 = Jieqi.cal.component(.day, from: tmp2)
        
        if day2 == dd {
            solarTerms = solarTerm[mm * 2]
        }
        
        return solarTerms
    }
    
    public func at(_ date:Date) -> String {
        let today:Date = {
            let now = Date()
            let cps = Jieqi.cal.dateComponents([.year,.month, .day], from: now)
            
            return Jieqi.cal.date(from: cps)!
        }()
        
        let cps = Jieqi.cal.dateComponents([.year, .month, .day], from: date)
        var result = ""
        
        if let jieqi = getjq(yyyy: cps.year!, mm: cps.month!, dd: cps.day!) {
            if date < today {
                result += String.localizedStringWithFormat(NSLocalizedString("This day was %@.", bundle: .module, comment: ""), jieqi.localizedString)
            } else if date == today {
                result += String.localizedStringWithFormat(NSLocalizedString("Today is %@.", bundle: .module, comment: ""), jieqi.localizedString)
            } else {
                result += String.localizedStringWithFormat(NSLocalizedString("This day will be %@.", bundle: .module, comment: ""), jieqi.localizedString)
            }
        } else {
            // get previus jieqi
            let (previousJieqi, previousCps) = previousJieqi(at: cps)
            let previousDate = Jieqi.cal.date(from: previousCps)!
            var day = Jieqi.cal.dateComponents([.day], from: previousDate, to: date).day!
            if previousDate < today {
                result += String(format: NSLocalizedString("%d days ago was %@.", bundle: .module, comment: ""), day, previousJieqi.localizedString)
            } else{
                result += String(format: NSLocalizedString("%d days later will be %@.", bundle: .module, comment: ""), day, previousJieqi.localizedString)
            }
            
            result += "\n"
            
            // get next jieqi
            let (nextJieqi, nextCps) = nextJieqi(at: cps)
            let nextDate = Jieqi.cal.date(from: nextCps)!
            day = Jieqi.cal.dateComponents([.day], from: date, to: nextDate).day!
            if nextDate < today {
                result += String(format: NSLocalizedString("%@ would be in %d days.", bundle: .module, comment: ""), nextJieqi.localizedString, day)
            } else {
                result += String(format: NSLocalizedString("%@ will be in %d days.", bundle: .module, comment: ""), nextJieqi.localizedString, day)
            }
        }
        
        return result
    }
    
    private func previousJieqi(at cps:DateComponents) -> (Name, DateComponents) {
        var cps = cps
        getPreviousDay(&cps)
        
        if let jieqi = getjq(yyyy: cps.year!, mm: cps.month!, dd: cps.day!) {
            return (jieqi, cps)
        }
        
        return previousJieqi(at: cps)
    }
    
    private func getPreviousDay(_ cps:inout DateComponents) {
        if cps.day! > 1 {
            cps.day! -= 1
        } else {
            let date = Jieqi.cal.date(from: cps)!
            let yesterday = Jieqi.cal.date(byAdding: .day, value: -1, to: date)!
            cps = Jieqi.cal.dateComponents([.year, .month, .day], from: yesterday)
        }
    }
    
    private func nextJieqi(at cps:DateComponents) -> (Name, DateComponents) {
        var cps = cps
        getNextDay(&cps)

        if let jieqi = getjq(yyyy: cps.year!, mm: cps.month!, dd: cps.day!) {
            return (jieqi, cps)
        }
        
        return nextJieqi(at: cps)
    }
    
    private func getNextDay(_ cps:inout DateComponents) {
        if cps.day! < 28 {
            cps.day! += 1
        } else {
            let date = Jieqi.cal.date(from: cps)!
            let tomorrow = Jieqi.cal.date(byAdding: .day, value: 1, to: date)!
            cps = Jieqi.cal.dateComponents([.year, .month, .day], from: tomorrow)
        }
    }
    
    public func whichSeason(at date:Date) -> Season {
        let cps = Jieqi.cal.dateComponents([.year, .month, .day], from: date)
        
        if let jieqi = getjq(yyyy: cps.year!, mm: cps.month!, dd: cps.day!) {
            return season(for: jieqi)
        } else {
            let (previousJieqi, _) = previousJieqi(at: cps)
            return season(for: previousJieqi)
        }
    }
    
    private func season(for jieqi:Name) -> Season {
        switch jieqi {
        case .lichun, .rainwater, .jingzhe, .vernalEquinox, .chingming, .guyu:
            return .spring
        case .lixia, .xiaoman, .mango, .summerSolstice, .smallHeat, .greatHeat:
            return .summer
        case .beginningOfAutumn, .chushu, .whiteDew, .autumnEquinox, .coldDew, .frost:
            return .autumn
        case .beginningOfWinter, .xiaoxue, .heavySnow, .winterSolstice, .xiaohan, .dahan:
            return .winter
        }
    }
    
    public enum Season:String {
        case spring
        case summer
        case autumn
        case winter
        
        public var localizedString:String {
            switch self {
            case .spring:
                return NSLocalizedString("Spring", bundle: .module, comment: "")
            case .summer:
                return NSLocalizedString("Summer", bundle: .module, comment: "")
            case .autumn:
                return NSLocalizedString("Autumn", bundle: .module, comment: "")
            case .winter:
                return NSLocalizedString("Winter", bundle: .module, comment: "")
            }
        }
    }
    
    public enum Name:CaseIterable {
        case xiaohan, dahan
        
        case lichun, rainwater, jingzhe
        case vernalEquinox
        case chingming, guyu
        
        case lixia, xiaoman, mango
        case summerSolstice
        case smallHeat, greatHeat
        
        case beginningOfAutumn
        case chushu, whiteDew
        case autumnEquinox
        case coldDew, frost
        
        case beginningOfWinter
        case xiaoxue, heavySnow
        case winterSolstice
        
        public var localizedString:String {
            switch self {
            case .xiaohan:
                return NSLocalizedString("Xiaohan", bundle: .module, comment: "")
            case .dahan:
                return NSLocalizedString("Dahan", bundle: .module, comment: "")
                
            case .lichun:
                return NSLocalizedString("Lichun", bundle: .module, comment: "")
            case .rainwater:
                return NSLocalizedString("Rainwater", bundle: .module, comment: "")
            case .jingzhe:
                return NSLocalizedString("Jingzhe", bundle: .module, comment: "")
            case .vernalEquinox:
                return NSLocalizedString("Vernal Equinox", bundle: .module, comment: "")
            case .chingming:
                return NSLocalizedString("Ching Ming", bundle: .module, comment: "")
            case .guyu:
                return NSLocalizedString("Guyu", bundle: .module, comment: "")
                
            case .lixia:
                return NSLocalizedString("Lixia", bundle: .module, comment: "")
            case .xiaoman:
                return NSLocalizedString("Xiaoman", bundle: .module, comment: "")
            case .mango:
                return NSLocalizedString("Mango", bundle: .module, comment: "")
            case .summerSolstice:
                return NSLocalizedString("Summer Solstice", bundle: .module, comment: "")
            case .smallHeat:
                return NSLocalizedString("Small Heat", bundle: .module, comment: "")
            case .greatHeat:
                return NSLocalizedString("Great Heat", bundle: .module, comment: "")
                
            case .beginningOfAutumn:
                return NSLocalizedString("Beginning of Autumn", bundle: .module, comment: "")
            case .chushu:
                return NSLocalizedString("Chushu", bundle: .module, comment: "")
            case .whiteDew:
                return NSLocalizedString("White Dew", bundle: .module, comment: "")
            case .autumnEquinox:
                return NSLocalizedString("Autumn Equinox", bundle: .module, comment: "")
            case .coldDew:
                return NSLocalizedString("Cold Dew", bundle: .module, comment: "")
            case .frost:
                return NSLocalizedString("Frost", bundle: .module, comment: "")
                
            case .beginningOfWinter:
                return NSLocalizedString("Beginning of Winter", bundle: .module, comment: "")
            case .xiaoxue:
                return NSLocalizedString("Xiaoxue", bundle: .module, comment: "")
            case .heavySnow:
                return NSLocalizedString("Heavy Snow", bundle: .module, comment: "")
            case .winterSolstice:
                return NSLocalizedString("Winter Solstice", bundle: .module, comment: "")
            }
        }
    }
}
