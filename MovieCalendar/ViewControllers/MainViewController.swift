//
//  MainViewController.swift
//  MovieCalendar
//
//  Created by Diel Barnes on 01/06/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum SpotlightPosition: Int {
    
    case top
    case topLeft
    case topRight
}

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var monthsWithMovies: [Int] = []
    var movies: [String: [Movie]] = [:]
    var requestPage: Int = 1
    var hasMoreResults: Bool = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var noMoviesLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //UI
        
        addSpotlight(inRect: CGRect(x: 0, y: 0, width: 70.0, height: 70.0), position: .topLeft)
        addSpotlight(inRect: CGRect(x: view.center.x - 35.0, y: 0, width: 70.0, height: 70.0), position: .top)
        addSpotlight(inRect: CGRect(x: UIScreen.main.bounds.width - 70.0, y: 0, width: 70.0, height: 70.0), position: .topRight)
        
        //Data
        
        
        
        // TODO: - local movies, upcoming movies, check for duplicates, test load more
        
        getMovies()
        
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Web Requests
    
    func getMovies() {
        
        if requestPage == 1 {
            activityIndicator.startAnimating()
        }
        
        //Create URL
        
        var countryCode = ""
        if let code = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            countryCode = code
        }
        
        let parameters: [URLQueryItem] = [URLQueryItem(name: "api_key", value: "11417eceae39883ea64f194cd0ed38ae"),
                                          //URLQueryItem(name: "region", value: countryCode),
                                          URLQueryItem(name: "page", value: "\(requestPage)")]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.themoviedb.org"
        urlComponents.path = "/3/movie/now_playing"
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
                        
                        if let results = json["results"].array {
                            
                            for result in results {
                                
                                var id: Int = -1
                                if let jsonId = result["id"].int {
                                    id = jsonId
                                }
                                
                                var title: String = ""
                                if let jsonTitle = result["title"].string {
                                    title = jsonTitle
                                }
                                
                                var posterPath: String?
                                if let jsonPosterPath = result["poster_path"].string {
                                    posterPath = jsonPosterPath
                                }
                                
                                var releaseDate = Date()
                                if let jsonReleaseDateString = result["release_date"].string, let jsonReleaseDate = jsonReleaseDateString.dateFromISO8601 {
                                    releaseDate = jsonReleaseDate
                                }
                                
                                let movie = Movie(id: id,
                                                  title: title,
                                                  poster: nil,
                                                  posterPath: posterPath,
                                                  genres: nil,
                                                  cast: nil,
                                                  synopsis: nil,
                                                  trailerPath: nil,
                                                  releaseDate: releaseDate)
                                
                                //Get only recent and upcoming movies in the current year
                                
                                if releaseDate.year() == Date().year() && releaseDate.weeks(fromDate: Date()) >= -1 {
                                    
                                    if !self.monthsWithMovies.contains(releaseDate.month()) {
                                        self.monthsWithMovies.append(releaseDate.month())
                                        self.monthsWithMovies.sort()
                                    }
                                    
                                    if self.movies.keys.contains(releaseDate.monthString()) {
                                        self.movies[releaseDate.monthString()]!.append(movie)
                                    }
                                    else {
                                        self.movies[releaseDate.monthString()] = [movie]
                                    }
                                }
                            }
                        }
                        
                        //Sort movies by release date
                        
                        for month in self.monthsWithMovies {
                            let monthString = DateFormatter().monthSymbols[month-1]
                            self.movies[monthString]?.sort {
                                return $0.releaseDate < $1.releaseDate
                            }
                        }
                        
                        //Check for more results
                        
                        if self.requestPage == json["total_pages"].int {
                            self.hasMoreResults = false
                        }
                        else {
                            self.hasMoreResults = true
                            self.requestPage += 1
                        }
                        
                        //Manage UI
                        
                        if self.movies.count == 0 {
                            self.noMoviesLabel.isHidden = false
                        }
                        else {
                            self.movieCollectionView.reloadData()
                        }
                    }
                    
                case .failure(let error):
                    
                    self.activityIndicator.stopAnimating()
                    
                    //Display error
                    
                    if self.requestPage == 1 {
                        
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
                        
                        let alertController = UIAlertController(title: "Failed To Get Movies", message: message, preferredStyle: .alert)
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                            self.noMoviesLabel.isHidden = false
                        })
                        alertController.addAction(cancelAction)
                        
                        let refreshAction = UIAlertAction(title: "Try Again", style: .default, handler: { action in
                            self.getMovies()
                        })
                        alertController.addAction(refreshAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Spotlight Effect
    
    func addSpotlight(inRect rect: CGRect, position: SpotlightPosition) {
        
        //Color gradient
        
        let spotlightColorPath = UIBezierPath()
        spotlightColorPath.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        spotlightColorPath.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        spotlightColorPath.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.size.height))
        spotlightColorPath.addLine(to: CGPoint(x: rect.origin.x, y: rect.size.height))
        spotlightColorPath.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        
        let spotlightColor = CAShapeLayer()
        spotlightColor.shadowOffset = CGSize.zero
        spotlightColor.shadowColor = UIColor(red: 80.0/255.0, green: 194.0/255.0, blue: 231.0/255.0, alpha: 1.0).cgColor
        spotlightColor.shadowRadius = 30.0
        spotlightColor.shadowOpacity = 0.5
        spotlightColor.shadowPath = spotlightColorPath.cgPath
        view.layer.addSublayer(spotlightColor)
        
        //Spotlight origin
        
        let spotlightOriginPath = UIBezierPath()
        var x: CGFloat = 0
        let length: CGFloat = rect.size.width/2 - 5.0
        
        if position == .top {
            x = rect.midX - (length/2)
        }
        else if position == .topLeft {
            x = rect.origin.x
        }
        else if position == .topRight {
            x = rect.origin.x + rect.size.width - length
        }
        
        spotlightOriginPath.move(to: CGPoint(x: x, y: rect.origin.y))
        spotlightOriginPath.addLine(to: CGPoint(x: x + length, y: rect.origin.y))
        spotlightOriginPath.addLine(to: CGPoint(x: x + length, y: length))
        spotlightOriginPath.addLine(to: CGPoint(x: x, y: length))
        spotlightOriginPath.addLine(to: CGPoint(x: x, y: rect.origin.y))
        
        let spotlightOrigin = CAShapeLayer()
        spotlightOrigin.shadowOffset = CGSize.zero
        spotlightOrigin.shadowColor = UIColor.white.cgColor
        spotlightOrigin.shadowRadius = 15.0
        spotlightOrigin.shadowOpacity = 1.0
        spotlightOrigin.shadowPath = spotlightOriginPath.cgPath
        view.layer.addSublayer(spotlightOrigin)
    }
    
    // MARK: - Collection View Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return monthsWithMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let monthString = DateFormatter().monthSymbols[monthsWithMovies[section]-1]
        if let moviesDuringMonth = movies[monthString] {
            return moviesDuringMonth.count
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view: UICollectionReusableView
        
        if kind == UICollectionElementKindSectionHeader {
            
            view = collectionView .dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "MonthHeaderView", for: indexPath)
            
            //Set section title
            
            let label = view.viewWithTag(123) as! UILabel
            label.text = DateFormatter().monthSymbols[monthsWithMovies[indexPath.section]-1].uppercased()
            
            //Adjust label width
            
            let maxSize = CGSize(width: 110.0, height: 29.0)
            var size = label.sizeThatFits(maxSize)
            size.width += 30.0
            if size.width < 83.0 {
                size.width = 83.0
            }
            
            for contraint in label.constraints {
                if contraint.firstAttribute == NSLayoutAttribute.width {
                    contraint.constant = size.width
                }
            }
            
            //Add film strip border
            
            let view = view.viewWithTag(456)
            view?.backgroundColor = UIColor(patternImage: UIImage(named:"film-strip")!)
        }
        else {
            view = UICollectionReusableView()
        }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        
        //Get proportional cell size (movie posters provided by The Movie DB are 160 x 240)
        
        let padding: CGFloat = 10.0
        let width = (UIScreen.main.bounds.width - padding) / 3
        let height = ((240.0 * (width - padding)) / 160.0) + padding
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let sectionTitle = DateFormatter().monthSymbols[monthsWithMovies[indexPath.section]-1]
        if let moviesDuringMonth = movies[sectionTitle] {
            
            let movie = moviesDuringMonth[indexPath.row]
            
            cell.configureBannerLabel(withDate: movie.releaseDate)
            
            //Get movie poster
            
            if movie.poster != nil {
                cell.posterView.image = movie.poster
                cell.titleLabel.isHidden = true
            }
            else if movie.posterPath != nil, let url = URL(string: "https://image.tmdb.org/t/p/w160" + movie.posterPath!) {
                
                cell.posterView.setImage(withURL: url, placeholderImage: UIImage(named: "placeholder")!, completion: { image in
                    
                    if image != nil, let index = self.movies[sectionTitle]?.index(where: { $0.id == movie.id }) {
                        self.movies[sectionTitle]?[index].poster = image
                        cell.titleLabel.isHidden = true
                    }
                })
            }
            else {
                cell.posterView.image = nil
                cell.titleLabel.text = movie.title
                cell.titleLabel.isHidden = false
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let sectionTitle = DateFormatter().monthSymbols[monthsWithMovies[indexPath.section]-1]
        if let moviesDuringMonth = movies[sectionTitle]{
            
            let movie = moviesDuringMonth[indexPath.row]
            
            let viewController = storyboard!.instantiateViewController(withIdentifier: "MovieViewController") as! MovieViewController
            viewController.movie = movie
            show(viewController, sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //Load more results
        
        if hasMoreResults, indexPath.row == movies.count - 1 {
            
            hasMoreResults = false
            getMovies()
        }
    }
}

