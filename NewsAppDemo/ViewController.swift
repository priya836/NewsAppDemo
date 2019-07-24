//
//  ViewController.swift
//  NewsAppDemo
//
//  Created by Priya Arora on 22/07/19.
//  Copyright © 2019 Priya Arora. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    var article = [Article]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        
        
        
        updateTableContent()
        
    }
    
    func updateTableContent() {
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(self.fetchedhResultController.sections?[0].numberOfObjects)")
        } catch let error  {
            print("ERROR: \(error)")
        }
        callNewsApi()
    }
    
    private func createNewsEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let newsEntity = NSEntityDescription.insertNewObject(forEntityName: "NewsData", into: context) as? NewsData {
            newsEntity.author = dictionary["author"]as? String
            newsEntity.date = dictionary["date"]as? String
            newsEntity.desc = dictionary["description"]as? String
            newsEntity.image_url = dictionary["urlToImage"]as? String
            newsEntity.name = dictionary["name"]as? String
            newsEntity.title = dictionary["title"]as? String
            newsEntity.url = dictionary["url"]as? String
            return newsEntity
        }
        return nil
    }
    
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map{self.createNewsEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: NewsData.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "author", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
         frc.delegate = self
        return frc
    }()
    
    private func clearData() {
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewsData")
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    func callNewsApi() {
        
        let session = URLSession.shared
        let url = URL(string: "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=f27d3df679f64c3385dbdb7dd7969f90")!
        
        let task = session.dataTask(with: url) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                //let responsefromServer = try decoder.decode(Response.self, from: data!)
                //print(responsefromServer)
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                print(json)
               // self.parse(json: data!)
                
                
                
                if let  res = json as? [String: Any] {
                    if let articles = res["articles"] as? [[String: Any]] {
                        self.clearData()
                        self.saveInCoreDataWith(array: articles as [[String : AnyObject]])
                        self.parse(json: data!)
                        
//                        let dictionary = res
//                        if let theJSONData = try? JSONSerialization.data (
//                            withJSONObject: dictionary,
//                            options: []) {
//                            let theJSONText = String(data: theJSONData,
//                                                     encoding: .ascii)
//                        }
                    }
                }
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        
        task.resume()

}
    
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Articles.self, from: json) {
            article = jsonPetitions.articles
            print(article.count)
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            
        }
    }
    
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = tableview.dequeueReusableCell(withIdentifier: "cell")as? TableViewCellClass else {
            return UITableViewCell() }
//        if article.count != 0 {
//            cell.authorNameLbl.text = article[indexPath.row].author
//            cell.dateLbl.text = article[indexPath.row].date
//            cell.descLbl.text = article[indexPath.row].description
//            cell.titleLbl.text = article[indexPath.row].title
//            cell.downloadImage(from: URL(string: article[indexPath.row].image_url!)!)
//        }
        
        if let newsdata = fetchedhResultController.object(at: indexPath) as? NewsData {
            cell.setCellWith(data: newsdata)
        }
        
        return cell
       
    }
}


extension ViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableview.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableview.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableview.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableview.beginUpdates()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let nextVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController")as? DetailViewController {
            nextVC.index = indexPath.row
            navigationController?.pushViewController(nextVC, animated: false)
        }
    }
}


