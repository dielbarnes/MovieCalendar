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
import TagListView
import EventKit

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var movie: Movie?
    var genresRequestFinished: Bool = false
    var showGenres: Bool = false
    var castRequestFinished: Bool = false
    var showCast: Bool = false
    var showPlot: Bool = false
    var trailerRequestFinished: Bool = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: movieTableView.frame.size.width, height: 15.0))
        
        activityIndicator.startAnimating()
        getGenres()
        getCast()
        getTrailerYouTubeId()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return.portrait
    }
    
    // MARK: - Web Requests
    
    func getGenres() {
        
        guard movie != nil else {
            return
        }
        
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
                    
                    self.genresRequestFinished = true
                    if self.castRequestFinished && self.trailerRequestFinished {
                        self.activityIndicator.stopAnimating()
                    }
                    
                    //Parse JSON
                    
                    if let value = response.result.value {
                        
                        let json = JSON(value)
                        
                        print(json)
                        
                        if let genres = json["genres"].array, genres.count > 0 {
                            
                            self.movie!.genres = [String]()
                            
                            for genre in genres {
                                
                                if let name = genre["name"].string {
                                    self.movie!.genres?.append(name)
                                }
                            }
                            
                            self.movieTableView.reloadData()
                        }
                    }
                    
                case .failure:
                    
                    self.genresRequestFinished = true
                    if self.castRequestFinished && self.trailerRequestFinished {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    func getCast() {
        
        guard movie != nil else {
            return
        }
        
        //Create URL
        
        let parameters: [URLQueryItem] = [URLQueryItem(name: "api_key", value: "11417eceae39883ea64f194cd0ed38ae")]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.themoviedb.org"
        urlComponents.path = "/3/movie/\(movie!.id)/credits"
        urlComponents.queryItems = parameters
        
        if let url = urlComponents.url {
            
            //Send request
            
            Alamofire.request(url).validate().responseJSON { response in
                
                switch response.result {
                    
                case .success:
                    
                    self.castRequestFinished = true
                    if self.genresRequestFinished && self.trailerRequestFinished {
                        self.activityIndicator.stopAnimating()
                    }
                    
                    //Parse JSON
                    
                    if let value = response.result.value {
                        
                        let json = JSON(value)
                        
                        print(json)
                        
                        if let array = json["cast"].array, array.count > 0 {
                            
                            self.movie!.cast = [Cast]()
                            
                            for person in array {
                                
                                var name: String = ""
                                if let jsonName = person["name"].string {
                                    name = jsonName
                                }
                                
                                var imagePath: String = ""
                                if let jsonImagePath = person["profile_path"].string {
                                    imagePath = jsonImagePath
                                }
                                
                                let cast = Cast(name: name,
                                                imagePath: imagePath)
                                
                                self.movie!.cast?.append(cast)
                                if self.movie!.cast?.count == 4 {
                                    break
                                }
                            }
                            
                            self.movieTableView.reloadData()
                        }
                    }
                    
                case .failure:
                    
                    self.castRequestFinished = true
                    if self.genresRequestFinished && self.trailerRequestFinished {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    func getTrailerYouTubeId() {
        
        guard movie != nil else {
            return
        }
        
        //Create URL
        
        let parameters: [URLQueryItem] = [URLQueryItem(name: "api_key", value: "11417eceae39883ea64f194cd0ed38ae")]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.themoviedb.org"
        urlComponents.path = "/3/movie/\(movie!.id)/videos"
        urlComponents.queryItems = parameters
        
        if let url = urlComponents.url {
            
            //Send request
            
            Alamofire.request(url).validate().responseJSON { response in
                
                switch response.result {
                    
                case .success:
                    
                    //Parse JSON
                    
                    if let value = response.result.value {
                        
                        let json = JSON(value)
                        
                        print(json)
                        
                        if let videos = json["results"].array, videos.count > 0 {
                            
                            for video in videos {
                                
                                if let site = video["site"].string, site == "YouTube", let key = video["key"].string {
                                    self.movie?.trailerYouTubeId = key
                                    break
                                }
                            }
                        }
                        
                        if self.movie?.trailerYouTubeId != nil {
                            self.getTrailerStreamUrl()
                        }
                        else {
                            self.trailerRequestFinished = true
                            if self.genresRequestFinished && self.castRequestFinished {
                                self.activityIndicator.stopAnimating()
                            }
                        }
                    }
                    
                case .failure:
                    
                    self.trailerRequestFinished = true
                    if self.genresRequestFinished && self.castRequestFinished {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    func getTrailerStreamUrl() {
        
        guard movie?.trailerYouTubeId != nil else {
            return
        }
        
        //Create URL
        
        let parameters: [URLQueryItem] = [URLQueryItem(name: "video_id", value: movie!.trailerYouTubeId)]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.youtube.com"
        urlComponents.path = "/get_video_info"
        urlComponents.queryItems = parameters
        
        if let url = urlComponents.url {
            
            //Send request
            
            Alamofire.request(url).validate().responseString { response in
                
                switch response.result {
                    
                case .success:
                    
                    self.trailerRequestFinished = true
                    if self.genresRequestFinished && self.castRequestFinished {
                        self.activityIndicator.stopAnimating()
                    }
                    
                    //Parse response string
                    
                    if let value = response.result.value {
                        
                        let dict = value.dictionaryFromQueryStringComponents()
                        if let status = dict["status"] {
                            
                            if status == "ok", let streamMap = dict["url_encoded_fmt_stream_map"] {
                                
                                for component in streamMap.components(separatedBy: ",") {
                                    
                                    let streamDict = component.dictionaryFromQueryStringComponents()
                                    
                                    if let type = streamDict["type"], type.contains("mp4"), let urlString = streamDict["url"]?.removingPercentEncoding, let url = URL(string: urlString) {
                                        
                                        self.movie!.trailerStreamUrl = url
                                        break
                                    }
                                }
                                
                                self.movieTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                            }
                        }
                    }
                    
                case .failure:
                    
                    self.trailerRequestFinished = true
                    if self.genresRequestFinished && self.castRequestFinished {
                        self.activityIndicator.stopAnimating()
                    }
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
                numberOfRows += 2
            }
            if let plot = movie!.plot, plot.characters.count > 0, plot != "no movie overview", plot != "No movie found." {
                showPlot = true
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
    
    func plotHeaderRow() -> Int {
        
        var row: Int = 2
        
        if showGenres {
            row += 1
        }
        if showCast {
            row += 2
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
            
            //Get proportional cell size (movie backdrops provided by The Movie DB are 533 x 300)
            
            let padding: CGFloat = 20.0
            let width = UIScreen.main.bounds.width
            let height = (300.0 * width / 533.0) + padding
            return height
        }
        else if (showCast && indexPath.row == castHeaderRow()) || (showPlot && indexPath.row == plotHeaderRow()) { //HeaderCell
            return 40.0
        }
        else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1 || (showGenres && indexPath.row == 2) { //TitleCell, GenresCell
            return 64.0
        }
        else if showPlot && indexPath.row == plotHeaderRow() + 1 { //PlotCell
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
            
            //Set backdrop
            
            let imageView = cell.viewWithTag(123) as! UIImageView
            
            if movie?.backdrop != nil {
                imageView.image = movie?.backdrop
            }
            else if let path = movie?.backdropPath, let url = URL(string: "https://image.tmdb.org/t/p/w533_and_h300_bestv2" + path) {
                
                imageView.setImage(withURL: url, placeholderImage: UIImage(named: "backdrop-placeholder")!, squareCrop: false, completion: { image in
                    if image != nil {
                        self.movie?.backdrop = image
                    }
                })
            }
            else {
                imageView.image = UIImage(named: "backdrop-placeholder")
            }
            
            //Play button
            
            if movie?.trailerStreamUrl != nil {
                
                let button = cell.viewWithTag(456) as! UIButton
                button.isHidden = false
            }
        }
        else if indexPath.row == 1 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
            
            //Set title and release date
            
            cell.textLabel?.text = movie?.title
            if let month = movie?.releaseDate.monthString(), let day = movie?.releaseDate.day() {
                cell.detailTextLabel?.text = "\(month) \(day)"
            }
            
            //Save to calendar button
            
            if let releaseDate = movie?.releaseDate {
                
                if releaseDate.month() == Date().month() && releaseDate.day() == Date().day() {
                    
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60.0, height: 21.0))
                    label.font = UIFont(name:"Futura-Medium", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
                    label.textColor = UIColor(red: 237.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
                    label.textAlignment = .right
                    label.text = "TODAY"
                    cell.accessoryView = label
                }
                else if releaseDate.month() > Date().month() || (releaseDate.month() == Date().month() && releaseDate.day() > Date().day()) {
                    
                    let button = UIButton(type: .custom)
                    button.frame = CGRect(x: 0, y: 0, width: 40.0, height: 40.0)
                    button.setImage(UIImage(named: "save-calendar"), for: .normal)
                    button.addTarget(self, action: #selector(saveToCalendarButtonTapped), for: .touchUpInside)
                    cell.accessoryView = button
                }
            }
        }
        else if showGenres && indexPath.row == 2 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "GenresCell", for: indexPath)
            
            //Set genres
            
            let tagListView = cell.viewWithTag(123) as! TagListView
            
            if let genres = movie?.genres, tagListView.tagViews.count == 0 {
                
                tagListView.textFont = UIFont(name:"Avenir", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
                tagListView.addTags(genres)
            }
        }
        else if showCast && indexPath.row == castHeaderRow() {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath)
            
            cell.textLabel?.text = "Cast"
        }
        else if showCast && indexPath.row == castHeaderRow() + 1 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "CastCell", for: indexPath)
            
            //Set cast
            
            if let cast = movie?.cast {
                
                for i in 0 ... cast.count - 1 {
                    (cell as! CastCell).configureCast(cast[i], index: i)
                }
            }
        }
        else if showPlot && indexPath.row == plotHeaderRow() {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath)
            
            cell.textLabel?.text = "Plot"
        }
        else {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "PlotCell", for: indexPath)
            
            //Set plot
            
            if let plot = movie?.plot {
                
                if plot.contains("\r") {
                    
                    let font = UIFont(name:"Avenir", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
                    
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.firstLineHeadIndent = 20.0
                    
                    let attributes = [NSForegroundColorAttributeName: UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0), NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle]
                    
                    cell.textLabel?.attributedText = NSMutableAttributedString(string: plot, attributes: attributes)
                }
                else {
                    cell.textLabel?.text = plot
                }
            }
        }
        
        return cell
    }
    
    // MARK: - Button Methods
    
    @IBAction func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playButtonTapped() {
        
        //Play trailer
        
        if let url = movie?.trailerStreamUrl {
            
            let viewController = TrailerPlayerViewController(url: url)
            show(viewController, sender: self)
        }
    }
    
    func saveToCalendarButtonTapped() {
        
        guard movie != nil else {
            return
        }
        
        //Save movie release date to calendar
        
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: EKEntityType.event, completion: { granted, accessError in
            
            if granted && accessError == nil {
                
                let event = EKEvent(eventStore: eventStore)
                event.title = self.movie!.title
                event.startDate = self.movie!.releaseDate
                event.endDate = self.movie!.releaseDate
                event.isAllDay = true
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                DispatchQueue.global(qos: .background).async {
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.startAnimating()
                    }
                    
                    do {
                        
                        try eventStore.save(event, span: .thisEvent)
                        
                        DispatchQueue.main.async {
                            
                            self.activityIndicator.stopAnimating()
                            self.showAlert(title: nil, message: "Successfully saved to calendar")
                        }
                        
                    } catch let error {
                        
                        DispatchQueue.main.async {
                            
                            self.activityIndicator.stopAnimating()
                            self.showAlert(title: "Failed To Save To Calendar", message: error.localizedDescription)
                        }
                    }
                }
            }
            else {
                
                var title: String?
                var message: String?
                if !granted {
                    title = "Calendar Access Required"
                    message = "Go to Settings > Privacy > Calendars and switch MovieCalendar to ON"
                }
                else {
                    title = "Failed To Access Calendar"
                    message = accessError?.localizedDescription
                }
                
                self.showAlert(title: title, message: message)
            }
        })
    }
    
    // MARK: - Alert Methods
    
    func showAlert(title: String?, message: String?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}
