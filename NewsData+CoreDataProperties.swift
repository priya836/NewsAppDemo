//
//  NewsData+CoreDataProperties.swift
//  NewsAppDemo
//
//  Created by Priya Arora on 23/07/19.
//  Copyright © 2019 Priya Arora. All rights reserved.
//
//

import Foundation
import CoreData


extension NewsData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsData> {
        return NSFetchRequest<NewsData>(entityName: "NewsData")
    }

    @NSManaged public var author: String?
    @NSManaged public var title: String?
    @NSManaged public var name: String?
    @NSManaged public var date: String?
    @NSManaged public var desc: String?
    @NSManaged public var image_url: String?

}
