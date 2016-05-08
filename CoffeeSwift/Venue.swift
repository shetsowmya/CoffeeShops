//
//  Venue.swift
//  CoffeeSwift
//
//  Created by Nidhi on 6/05/2016.
//  Copyright © 2016 ShetCo. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class Venue: Object
{
    dynamic var id:String = ""
    dynamic var name:String = ""
    
    dynamic var latitude:Float = 0
    dynamic var longitude:Float = 0
    
    dynamic var address:String = ""
    dynamic var distance:Float = 0
    
    var coordinate:CLLocation {
        return CLLocation(latitude: Double(latitude), longitude: Double(longitude));
    }
    
    override static func primaryKey() -> String?
    {
        return "id";
    }
}