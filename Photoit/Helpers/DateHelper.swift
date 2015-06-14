//
//  DateHelper.swift
//  Photoit
//
//  Created by Roman Barzyczak on 13.06.2015.
//  Copyright (c) 2015 Photoit. All rights reserved.
//

import Foundation


struct DateHelper {
    static func niceCurrentDate() -> NSString {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        formatter.dateStyle = .ShortStyle
        return formatter.stringFromDate(date)
    }
    
    
    static func daysBetween(startDate:NSDate,endDate:NSDate) -> Int{
        
        let day1 = NSCalendar.currentCalendar().ordinalityOfUnit(NSCalendarUnit.DayCalendarUnit, inUnit: NSCalendarUnit.EraCalendarUnit, forDate: startDate)
        
        let day2 = NSCalendar.currentCalendar().ordinalityOfUnit(NSCalendarUnit.DayCalendarUnit, inUnit: NSCalendarUnit.EraCalendarUnit, forDate: endDate)
        
        let daysbetween = day2 - day1
        
        
        return daysbetween
    }


}