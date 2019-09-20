//
//  ComplicationController.swift
//  test WatchKit Extension
//
//  Created by Reuben on 14/02/19.
//  Copyright © 2019 Reuben. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    
    @available(watchOSApplicationExtension 5.0, *)
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        
        switch complication.family {
            
            
        case .graphicBezel:
            
            let template: CLKComplicationTemplateGraphicBezelCircularText = CLKComplicationTemplateGraphicBezelCircularText()
            
            let simpleText: CLKSimpleTextProvider = CLKSimpleTextProvider(text: "Graphic Bezel")
            
            template.textProvider = simpleText
            
            handler(template)
            
        case .graphicCorner:
            
            let template: CLKComplicationTemplateGraphicCornerCircularImage = CLKComplicationTemplateGraphicCornerCircularImage()
            
            let simpleImageProvider: CLKFullColorImageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Graphic Corner") ?? UIImage())
            
            template.imageProvider = simpleImageProvider
            
            handler(template)
            
        case .graphicCircular:
            
            let template: CLKComplicationTemplateGraphicCircularImage = CLKComplicationTemplateGraphicCircularImage()
            
            let simpleImageProvider: CLKFullColorImageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Graphic Circular") ?? UIImage())
            
            template.imageProvider = simpleImageProvider
            
            handler(template)
            
        case .utilitarianLarge:
            
            let template:CLKComplicationTemplateUtilitarianLargeFlat = CLKComplicationTemplateUtilitarianLargeFlat()
            
            let simpleText: CLKSimpleTextProvider = CLKSimpleTextProvider(text: "Clyde For Discord")
            
            template.textProvider = simpleText
            
            handler(template)
            
        default:
            
            handler(nil)
            
        }
        
    }
    
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
}
