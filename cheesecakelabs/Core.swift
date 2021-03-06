//
//  File.swift
//  ckl
//
//  Created by Israel Tavares on 7/5/15.
//  Copyright (c) 2015 Coruja Virtual. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON

/**
CoreData CRUD helper class
*/
public class Core {
    

    public func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        return managedContext;
    }
    
    /**
    - TODO: Use a library to map objects - JSON to swift objects
    check https://github.com/tristanhimmelman/AlamofireObjectMapper
    */
    func createData(articles: NSMutableArray) -> Bool {
        let managedContext = getContext()
        
        let entity =  NSEntityDescription.entityForName("Article",
            inManagedObjectContext:managedContext)
        
        /**
        Loop through articles array
        */
        for item in articles
        {
            /**
            Check if data exists in CoreData before saving it
            */
            if(dataExists((item["title"] as? String)!, website: (item["website"] as? String)!) == 0) {
                
                let article = Article(entity: entity!, insertIntoManagedObjectContext: managedContext)

                /**
                Key, Value loop through item
                */
                for(k, v) in item as! [String: AnyObject]
                {
                    if let value = v as? String
                    {
                        /**
                        Convert date to NSDate
                        */
                        if k == "date"
                        {
                            article.setValue(StringDateConversion.getNSDate(value), forKey: k)
                        }
                        else
                        {
                            article.setValue(value, forKey: k)
                        }
                    }
                }
                
            }
            
        }
        
        do {
            
            try managedContext.save()
            
            return true
            
        } catch {
            
            return false
            
        }
        
    }
    
    /**
    Check if data exists in CoreData before saving it
    - parameter title of the website of the article (id would be preferable)
    - returns: int count of duplicates
    */
    func dataExists(title: String, website: String) -> Int {
        let managedContext = getContext()
        
        let entity = NSEntityDescription.entityForName("Article", inManagedObjectContext: managedContext)
        let fetchRequest = NSFetchRequest()
        
        let predicate_website = NSPredicate(format: "website = %@", website)
        let predicate_title = NSPredicate(format: "title = %@", website)

        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [predicate_title, predicate_website])

        fetchRequest.predicate = predicate
        fetchRequest.entity = entity
        
        var error: NSError?
        let count: Int =  managedContext.countForFetchRequest(fetchRequest, error: &error)
        if count == NSNotFound {
            print("Error trying to cound object in CoreData");
            return 0;
        }
        
        return count
    }
    
    /**
    Retrives sorted data based on parameter
    - parameter sort by - title, website, or author. Though is possible to sort by any parameter contained in the Article model
    - returns: Array of Article model
    */
    func retriveData(sortBy: String) -> [Article]? {
        
        let managedContext = getContext()
        
        let entity = NSEntityDescription.entityForName("Article", inManagedObjectContext: managedContext)
        let fetchRequest = NSFetchRequest()
        let sortDescriptor = NSSortDescriptor(key: sortBy, ascending: true)
        let sortDescriptors = [sortDescriptor]
        
        
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false;
        fetchRequest.entity = entity
        fetchRequest.resultType = NSFetchRequestResultType.ManagedObjectResultType
        fetchRequest.includesPropertyValues = true
        
        do {
            
            var articles = [Article]()
            
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [Article]
            
            articles = fetchedResults!
            
            return articles
            
        } catch let fetchError as NSError {
            print("getGalleryForItem error: \(fetchError.localizedDescription)")
            return nil
        }
    }
    
    /**
    // TODO: Select Article by title and website and update read field
    */
    func updateData() {
        let managedContext = getContext()
        let fetchRequest = NSFetchRequest(entityName:"Article")
        let predicate = NSPredicate(format: "website = %@", "Into Mobile")
        
        fetchRequest.returnsObjectsAsFaults = false;
        fetchRequest.predicate = predicate
        
        do {
            
            let fetchedResults: NSArray = try managedContext.executeFetchRequest(fetchRequest)
        
            let article: NSManagedObject = fetchedResults.objectAtIndex(0) as! NSManagedObject
            
            article.setValue(true, forKey: "read")
            
            try managedContext.save()

        } catch {
            
            print("Could not save to core data")
        }
        
    }
    
}