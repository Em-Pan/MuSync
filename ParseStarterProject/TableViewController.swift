//
//  TableViewController.swift
//  ParseStarterProject
//
//  Created by Mau Pan on 10/7/15.
//  Copyright © 2015 Mau. All rights reserved.
//

import UIKit
import Parse


class TableViewController: UITableViewController {
    
    var songNames = [""]
    var songIds = [""]
    var isLiked = ["":false]
    
    var playlistCode = "1234"
    
    var refresher: UIRefreshControl!
    
    
    
    
    func refresh() {
        //var query = PFObject.query()
        var query = PFQuery(className: "songs")
        
        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if let objects = objects {
                
                self.songNames.removeAll(keepCapacity: true)
                self.songIds.removeAll(keepCapacity: true)
                self.isLiked.removeAll(keepCapacity: true)
                
                for object in objects {
                    
                    if let object = object as? PFObject {
                        
                        if object["playlistId"] as! String == self.playlistCode {
                            
                            self.songNames.append(object["songName"] as! String)
                            self.songIds.append(object.objectId!)
                            
                            var query = PFQuery(className: "songs")
                            /*
                            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
                            query.whereKey("following", equalTo: user.objectId!)
                            */
                            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                
                                if let objects = objects {
                                    
                                    if objects.count > 0 {
                                        
                                        self.isLiked[object["songId"] as! String] = true
                                    } else {
                                        
                                        self.isLiked[object["songId"] as! String] = false
                                        
                                        
                                    }
                                    
                                }
                                if self.isLiked.count == self.songIds.count {
                                    
                                    self.tableView.reloadData()
                                    self.refresher.endRefreshing()
                                }
                            })
                            
                        }
                        
                    }
                }
                
            }
            
            
        })
        
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refresher)
        
        refresh()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songIds.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = songNames[indexPath.row]
        
        if isLiked[songIds[indexPath.row]] == true {
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        

        
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if isLiked[songIds[indexPath.row]] == false {
            
            isLiked[songIds[indexPath.row]] = true
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            var query = PFQuery(className: "songs")
            var obj = query.getObjectWithId(songIds[indexPath.row])
            print(obj)

            //songs.addUniqueObjectsFromArray([PFUser.currentUser()!.objectId!], forKey: "usersLiked")
        } else {
            isLiked[songIds[indexPath.row]] = false
            cell.accessoryType = UITableViewCellAccessoryType.None
            var query = PFQuery(className: "songs")
            
            query.whereKey("usersLiked", equalTo: PFUser.currentUser()!.objectId!)
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if let objects = objects {
                    
                    for object in objects {
                        
                        object.deleteInBackground()
                        
                    }
                }
                
            })
            
            
            
            
            
        }
        
        
    }
    
}
