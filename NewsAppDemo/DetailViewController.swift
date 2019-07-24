//
//  DetailViewController.swift
//  NewsAppDemo
//
//  Created by Priya Arora on 23/07/19.
//  Copyright © 2019 Priya Arora. All rights reserved.
//

import UIKit
import CoreData
class DetailViewController: UIViewController {

    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var authorName: UILabel!
    
    var index = Int()
    var url = String()
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchdata()
        // Do any additional setup after loading the view.
    }
    
    func fetchdata() {
        
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(self.fetchedhResultController.sections?[0].numberOfObjects)")
        } catch let error  {
            print("ERROR: \(error)")
        }
       
        if let newsdata = fetchedhResultController.object(at: IndexPath(row: index, section: 0)) as? NewsData {
            print(newsdata)
            descLbl.text = newsdata.desc
            titleLbl.text = newsdata.title
            dateLbl.text = newsdata.date
            authorName.text = newsdata.author
            url = newsdata.url ?? ""
            if let urlstring = newsdata.image_url {
                downloadImage(from: URL(string: urlstring)!)
            }
            
        }
    }
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: NewsData.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "author", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        // frc.delegate = self
        return frc
    }()
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.imageview.image = UIImage(data: data)
            }
        }
    }

    @IBAction func moreDetailBtnClicked(_ sender: UIButton) {
        
        if url != "" {
            guard let url = URL(string: url) else { return }
            UIApplication.shared.openURL(url)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
