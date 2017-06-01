//
//  MainViewController.swift
//  MovieCalendar
//
//  Created by Diel Barnes on 01/06/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var monthsWithMovies: [Int] = []
    var movies: [String: [Movie]] = [:]
    var hasMoreResults: Bool = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let page: Int = 1
        
        let parameters: [URLQueryItem] = [URLQueryItem(name: "api_key", value: "11417eceae39883ea64f194cd0ed38ae"),
                                          URLQueryItem(name: "region", value: "PH"),
                                          URLQueryItem(name: "page", value: "\(page)")]
        
        var urlComponents = URLComponents(string: "https://api.themoviedb.org/3/movie/now_playing")
        urlComponents?.queryItems = parameters
        
        if let url = urlComponents?.url {
            
            Alamofire.request(url).validate().responseJSON { response in
                
                switch response.result {
                    
                case .success:
                    
                    if let value = response.result.value {
                        
                        let json = JSON(value)
                        
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
                                
                                var posterPath: String = ""
                                if let jsonPosterPath = result["poster_path"].string {
                                    posterPath = jsonPosterPath
                                }
                                
                                var releaseDate = Date()
                                if let jsonReleaseDateString = result["release_date"].string, let jsonReleaseDate = jsonReleaseDateString.dateFromISO8601 {
                                    releaseDate = jsonReleaseDate
                                }
                                
                                let movie = Movie(id: id,
                                                  title: title,
                                                  posterPath: posterPath,
                                                  genres: nil,
                                                  cast: nil,
                                                  synopsis: nil,
                                                  trailerPath: nil,
                                                  releaseDate: releaseDate)
                                
                                if !self.monthsWithMovies.contains(releaseDate.month()) {
                                    self.monthsWithMovies.append(releaseDate.month())
                                    self.monthsWithMovies.sort()
                                }
                                
                                let monthString = DateFormatter().monthSymbols[releaseDate.month()-1]
                                
                                if self.movies.keys.contains(monthString) {
                                    self.movies[monthString]!.append(movie)
                                }
                                else {
                                    self.movies[monthString] = [movie]
                                }
                            }
                        }
                        
                        for month in self.monthsWithMovies {
                            let monthString = DateFormatter().monthSymbols[month-1]
                            self.movies[monthString]?.sort {
                                return $0.releaseDate < $1.releaseDate
                            }
                        }
                        
                        if page == json["total_pages"].int {
                            self.hasMoreResults = false
                        }
                        else {
                            self.hasMoreResults = true
                        }
                        
                        self.movieCollectionView.reloadData()
                    }
                    
                case .failure(let error):
                    
                    let alertController = UIAlertController(title: "Failed To Get Movies", message: error.localizedDescription, preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(action)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Collection View Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return monthsWithMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view: UICollectionReusableView
        
        if kind == UICollectionElementKindSectionHeader {
            
            view = collectionView .dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "MonthHeaderView", for: indexPath)
            
            let label = view.viewWithTag(123) as! UILabel
            label.text = DateFormatter().monthSymbols[monthsWithMovies[indexPath.section]-1].uppercased()
            
            // TODO: - Label size
        }
        else {
            view = UICollectionReusableView()
        }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionTitle = DateFormatter().monthSymbols[monthsWithMovies[section]-1]
        if let moviesDuringMonth = movies[sectionTitle] {
            return moviesDuringMonth.count
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        
        let width = (UIScreen.main.bounds.width - 45.0) / 3
        let height = ((240.0 * (width - 10.0)) / 160.0) + 34.0
        return CGSize(width: width, height: height)
    }
    
    func colletionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: NSInteger) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath)
        
        let sectionTitle = DateFormatter().monthSymbols[monthsWithMovies[indexPath.section]-1]
        if let moviesDuringMonth = movies[sectionTitle] {
            
            let movie = moviesDuringMonth[indexPath.row]
            
            let imageView = cell.viewWithTag(123) as! UIImageView
            if let url = URL(string: "https://image.tmdb.org/t/p/w160" + movie.posterPath) {
                imageView.af_setImage(withURL: url)
            }
            
            // TODO: - Placeholder image, image view height
            
            let label = cell.viewWithTag(456) as! UILabel
            label.text = "\(movie.releaseDate.day())"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //let movie = movies[indexPath.row]
        
        /*let viewController = storyboard!.instantiateViewController(withIdentifier: "MovieViewController") as! MovieViewController
        viewController.movie = movie
        show(viewController, sender: self)*/
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if hasMoreResults, indexPath.row == movies.count - 1 {
            
            hasMoreResults = false
            //getMovies(page: )
        }
    }
}

