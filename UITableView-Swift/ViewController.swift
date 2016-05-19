//
//  ViewController.swift
//  UITableView-Swift
//
//  Created by Gazolla on 05/06/14.
//  Copyright (c) 2014 Gazolla. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    var items:[String] = []
    
    lazy var tableView : UITableView = {
        let tv = UITableView(frame:self.view.frame, style: .Grouped)
        tv.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        tv.delegate = self
        tv.dataSource = self
        tv.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()

    lazy var leftButton:UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, handler: { (sender) in
            if !self.items.isEmpty {
                if (self.leftButton.tag == 100){
                    self.tableView.setEditing(true, animated: true)
                    self.leftButton.tag = 200
                    self.leftButton.title = "Done"
                } else {
                    self.tableView.setEditing(false, animated: true)
                    self.leftButton.tag = 100
                    self.leftButton.title = "Edit"
                }
            }
        })
        barButtonItem.tag = 100
        return barButtonItem
    }()
    
    lazy var rightButton:UIBarButtonItem = {
        return UIBarButtonItem(title: "Add", style: .Plain , handler: { (sender) in
            let indexPath = NSIndexPath(forRow:self.items.count,inSection:0)
            self.items.append("1")
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "TableView on Swift"
        self.view.addSubview(self.tableView)
        self.navigationItem.rightBarButtonItem = self.rightButton
        self.navigationItem.leftBarButtonItem = self.leftButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView .dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel!.text = String(format: "%i", indexPath.row+1)
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        self.items.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle{
        return (UITableViewCellEditingStyle.Delete)
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath){
        self.tableView.moveRowAtIndexPath(sourceIndexPath, toIndexPath: destinationIndexPath)
        swap(&self.items[sourceIndexPath.row], &self.items[destinationIndexPath.row])
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        print("row = %d",indexPath.row)
    }

}

public typealias CKBarButtonHandler = (sender: UIBarButtonItem) -> Void
private var associatedEventHandle: UInt8 = 0

extension UIBarButtonItem {
    
    private var closuresWrapper: ClosureWrapper? {
        get {
            return objc_getAssociatedObject(self, &associatedEventHandle) as? ClosureWrapper
        }
        
        set {
            objc_setAssociatedObject(self, &associatedEventHandle, newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public convenience init(title:String, style: UIBarButtonItemStyle, handler: CKBarButtonHandler) {
        self.init(title:title, style: style, target: nil, action: #selector(UIBarButtonItem.handleAction))
        self.closuresWrapper = ClosureWrapper(handler: handler)
        self.target = self
    }
    
    @objc
    private func handleAction() {
        self.closuresWrapper?.handler(sender: self)
    }
}


private final class ClosureWrapper {
    private var handler: CKBarButtonHandler
    
    init(handler: CKBarButtonHandler) {
        self.handler = handler
    }
}

