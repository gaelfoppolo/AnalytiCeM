//
//  SessionViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 16/04/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import UIKit

import RealmSwift

class SessionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Constant
    
    let kCellIdentifier = "cellSession"
    
    // MARK: - Properties
    
    let realm = try! Realm()
    var sessions: Results<Session>?
    var notificationSession: NotificationToken? = nil
    
    // MARK: - IBOutlet
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Session"
        
        // being the delegate and the data source of the tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // register the cell
        self.tableView.register(UINib(nibName: "SessionTableViewCell", bundle: nil), forCellReuseIdentifier: kCellIdentifier)
        
        // get the sessions of the current user, descending order
        let currentUser = realm.objects(User.self).filter("isCurrent == true").first!
        sessions = realm
            .objects(Session.self)
            .filter(NSPredicate(format: "user == %@", currentUser))
            .sorted(byKeyPath: "id", ascending: false)
        
        // notifications, update tableView
        notificationSession = self.sessions?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let tableView = self?.tableView else { return }
            
            switch changes {
                case .initial:
                    // Results are now populated and can be accessed without blocking the UI
                    tableView.reloadData()
                    break
                case .update(_, let deletions, let insertions, let modifications):
                    // Query results have changed, so apply them to the UITableView
                    tableView.beginUpdates()
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                    tableView.endUpdates()
                    break
                case .error(let error):
                    fatalError("\(error)")
                    break
            }
        }
        
    }
    
    deinit {
        notificationSession?.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sessions?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // recover the cell
        let cell = self.tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath) as! SessionTableViewCell
        
        guard let currentSession = self.sessions?[indexPath.row] else { fatalError() }
        
        let interval = currentSession.end?.timeIntervalSince(currentSession.start as Date)
        
        guard let duration = interval else { fatalError() }
        
        cell.activityName.text = currentSession.activity?.label
        cell.date.text = currentSession.start.description
        cell.duration.text = duration.description
        
        // cell is configured
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var viewController: UserViewController = UserViewController(nibName: "UserViewController", bundle: nil)
        // todo: pass data
        
        // display the view
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }

}
