//
//  TableViewCellClass.swift
//  NewsAppDemo
//
//  Created by Priya Arora on 22/07/19.
//  Copyright © 2019 Priya Arora. All rights reserved.
//

import UIKit

class TableViewCellClass: UITableViewCell {

    @IBOutlet weak var outerview: UIView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var authorNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellWith(data: NewsData) {
        DispatchQueue.main.async {
            self.authorNameLbl.text = data.author
            self.dateLbl.text = data.date
            self.descLbl.text = data.desc
            self.titleLbl.text = data.title
            if let urlstring = data.image_url  {
                self.downloadImage(from: URL(string: urlstring)!)
            }
            
            
        }
    }
    
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

}
