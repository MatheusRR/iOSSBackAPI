//
//  iOSSBackAPIDelegate.swift
//  Pods
//
//  Created by Matheus on 14/06/17.
//  FIVE'S DEVELOPMENT LTDA
//

import Foundation
import MapKit

@objc public protocol iOSSBackAPIDelegate:NSObjectProtocol {
    var window:UIWindow? { get set }
    @objc optional func notificateWhenAPPIsActive(store_id:String, title:String, message:String)
    @objc optional func pointsLoaded(points:[CLCircularRegion])
    @objc optional func userClickedInNotificationSBack()
}
