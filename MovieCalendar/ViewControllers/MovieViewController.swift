//
//  MovieViewController.swift
//  MovieCalendar
//
//  Created by Diel Barnes on 03/06/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var movie: Movie?
    var showGenres: Bool = false
    var showCast: Bool = false
    var showSynopsis: Bool = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: movieTableView.frame.size.width, height: 15.0))
        
        getMovieDetails()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Web Requests
    
    func getMovieDetails() {
        
        guard movie != nil else {
            return
        }
        
        activityIndicator.startAnimating()
        
        //Create URL
        
        let parameters: [URLQueryItem] = [URLQueryItem(name: "api_key", value: "11417eceae39883ea64f194cd0ed38ae")]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.themoviedb.org"
        urlComponents.path = "/3/movie/\(movie!.id)"
        urlComponents.queryItems = parameters
        
        if let url = urlComponents.url {
            
            //Send request
            
            Alamofire.request(url).validate().responseJSON { response in
                
                switch response.result {
                    
                case .success:
                    
                    self.activityIndicator.stopAnimating()
                    
                    //Parse JSON
                    
                    if let value = response.result.value {
                        
                        let json = JSON(value)
                        
                        print(json)
                        
                        // TODO: - Get genres, cast, synopsis, trailer path
                        
                        //Manage UI
                        
                        self.movieTableView.reloadData()
                    }
                    
                case .failure(let error):
                    
                    self.activityIndicator.stopAnimating()
                    
                    //Display error
                    
                    var message = ""
                    
                    if let responseData = response.data {
                        
                        let json = JSON(responseData)
                        
                        if let statusMessage = json["status_message"].string {
                            message = statusMessage
                        }
                    }
                    else {
                        message = error.localizedDescription
                    }
                    
                    let alertController = UIAlertController(title: "Failed To Get Movie Details", message: message, preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alertController.addAction(action)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Table View Methods
    
    func numberOfRows() -> Int {
        
        if movie != nil {
            
            var numberOfRows: Int = 2
            
            if let count = movie!.genres?.count, count > 0 {
                showGenres = true
                numberOfRows += 1
            }
            if let count = movie!.cast?.count, count > 0 {
                showCast = true
                numberOfRows += Int(ceil(Double(count / 4))) + 1
            }
            if let synopsis = movie!.synopsis, synopsis.characters.count > 0 {
                showSynopsis = true
                numberOfRows += 2
            }
            
            return numberOfRows
        }
        else {
            return 0
        }
    }
    
    func castHeaderRow() -> Int {
        
        if showGenres {
            return 3
        }
        else {
            return 2
        }
    }
    
    func synopsisHeaderRow() -> Int {
        
        var row: Int = 2
        
        if showGenres {
            row += 1
        }
        if showCast, let count = movie?.cast?.count {
            row += Int(ceil(Double(count / 4))) + 1
        }
        
        return row
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 { //PosterCell
            return 231.0
        }
        else if (showCast && indexPath.row == castHeaderRow()) || (showSynopsis && indexPath.row == synopsisHeaderRow()) { //HeaderCell
            return 40.0
        }
        else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1 { //TitleCell
            return 64.0
        }
        else if showGenres && indexPath.row == 2 { //GenresCell
            return 54.0
        }
        else if showSynopsis && indexPath.row == synopsisHeaderRow() + 1 { //SynopsisCell
            return 30.0
        }
        else { //CastCell
            return 101.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        if indexPath.row == 0 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "BackdropCell", for: indexPath)
            
            //Set movie backdrop
            
            let imageView = cell.viewWithTag(123) as! UIImageView
            
            if movie?.backdrop != nil {
                imageView.image = movie?.backdrop
            }
            else if let path = movie?.backdropPath, let url = URL(string: "https://image.tmdb.org/t/p/w533_and_h300_bestv2" + path) {
                
                imageView.setImage(withURL: url, placeholderImage: UIImage(named: "backdrop-placeholder")!, completion: { image in
                    if image != nil {
                        self.movie?.backdrop = image
                    }
                })
            }
            else {
                imageView.image = UIImage(named: "backdrop-placeholder")
            }
            
            //Play button
            
            let button = cell.viewWithTag(456) as! UIButton
            if movie?.trailerPath != nil {
                button.isHidden = false
            }
        }
        else if indexPath.row == 1 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
            
            //Set movie title and release date
            
            cell.textLabel?.text = movie?.title
            if let month = movie?.releaseDate.monthString(), let day = movie?.releaseDate.day() {
                cell.detailTextLabel?.text = "\(month) \(day)"
            }
            
            //Save to calendar button
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 40.0, height: 40.0)
            button.setImage(UIImage(named: "save-calendar"), for: .normal)
            button.addTarget(self, action: #selector(saveToCalendarButtonTapped), for: .touchUpInside)
            cell.accessoryView = button
        }
        else if showGenres && indexPath.row == 2 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "GenresCell", for: indexPath)
            
            // TODO: - Genres cell
        }
        else if showCast && indexPath.row == castHeaderRow() {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath)
            
            cell.textLabel?.text = "Cast"
        }
        else if showSynopsis && indexPath.row == synopsisHeaderRow() {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath)
            
            cell.textLabel?.text = "Synopsis"
        }
        else if showSynopsis && indexPath.row == synopsisHeaderRow() + 1 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "SynopsisCell", for: indexPath)
            
            cell.textLabel?.text = movie?.synopsis
        }
        else {
            
            // TODO: - Cast cell
            
            cell = tableView.dequeueReusableCell(withIdentifier: "CastCell", for: indexPath)
            
            let imageView1 = cell.viewWithTag(1) as! UIImageView
            imageView1.layer.cornerRadius = imageView1.frame.size.width / 2
            imageView1.clipsToBounds = true
            
            let label1 = cell.viewWithTag(2) as! UILabel
            label1.text = ""
            
            let imageView2 = cell.viewWithTag(3) as! UIImageView
            imageView2.layer.cornerRadius = imageView2.frame.size.width / 2
            imageView2.clipsToBounds = true
            
            let label2 = cell.viewWithTag(4) as! UILabel
            label2.text = ""
            
            let imageView3 = cell.viewWithTag(5) as! UIImageView
            imageView3.layer.cornerRadius = imageView3.frame.size.width / 2
            imageView3.clipsToBounds = true
            
            let label3 = cell.viewWithTag(6) as! UILabel
            label3.text = ""
            
            let imageView4 = cell.viewWithTag(7) as! UIImageView
            imageView4.layer.cornerRadius = imageView4.frame.size.width / 2
            imageView4.clipsToBounds = true
            
            let label4 = cell.viewWithTag(8) as! UILabel
            label4.text = ""
        }
        
        return cell
    }
    
    // MARK: - Button Methods
    
    @IBAction func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playButtonTapped() {
        
        //Play trailer
        
        let viewController = storyboard!.instantiateViewController(withIdentifier: "TrailerViewController") as! TrailerViewController
        viewController.movieTrailerPath = movie?.trailerPath
        show(viewController, sender: self)
    }
    
    func saveToCalendarButtonTapped() {
        
        // TODO: - Save to calendar
    }
}
