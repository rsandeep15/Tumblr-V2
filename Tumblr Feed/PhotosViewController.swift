//
//  FotosViewController.swift
//  Tumblr Feed
//
//  Created by  Alex Sumak on 2/2/17.
//  Copyright © 2017  Alex Sumak. All rights reserved.
//

import AFNetworking
import UIKit

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    var posts: [NSDictionary] = []
    
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    var isMoreDataLoading = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(self.refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 240;
        tableView.insertSubview(refreshControl, at: 0)
        // Do any additional setup after loading the view.
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                         self.isMoreDataLoading = false
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                         self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                }
        });
        task.resume()
        
    }
    func refreshControlAction(_ refreshControl: UIRefreshControl){
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                         self.isMoreDataLoading = false
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                        self.tableView.reloadData()
                        refreshControl.endRefreshing()
                    }
                }
        });
        task.resume()

    }
    func loadMoreData(){
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&offset=\(self.posts.count)")
        let request = URLRequest(url: url!)
        let task : URLSessionDataTask = session.dataTask(with: request,
                                                                      completionHandler: { (data, response, error) in
                                                                        
            // Update flag
            self.isMoreDataLoading = false
            
            // ... Use the new data to update the data source ...
            if let data = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(
                    with: data, options:[]) as? NSDictionary {

                    let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                    self.posts += responseFieldDictionary["posts"] as! [NSDictionary]
                    self.tableView.reloadData()
                }
                                                                        }
        });
        task.resume()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath as IndexPath) as! PhotoCell
        
        // Configure YourCustomCell using the outlets that you've defined.
        let post = posts[indexPath.row]
        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary] {
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            if let imageUrl = URL(string: imageUrlString!) {
                  cell.foto.setImageWith(imageUrl)
            } else {
                // URL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
            }
        } else {
            // photos is nil. Good thing we didn't try to unwrap it!
        }
        
        return cell
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                
                isMoreDataLoading = true
                
                // Code to load more results
                loadMoreData()
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let vc = segue.destination as! PhotoDetailsViewController
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
        let post = posts[(indexPath?.row)!]
        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary] {
            if let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String {
                if let imageUrl = URL(string: imageUrlString) {
                    vc.imageURL = imageUrl; 
                }
                else {
                    // URL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
                }
            }
        } else {
            // photos is nil. Good thing we didn't try to unwrap it!
        }

        
        
    }
    

}
