//
//  MyPopoverViewController.swift
//  MacRecorder
//
//  Created by huhuegg on 2017/2/20.
//  Copyright © 2017年 huhuegg. All rights reserved.
//

import Cocoa

class MyPopoverViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    var data:Array<WindowInfo> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        initView()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        initData()
    }
    @IBAction func updateListButtonClicked(_ sender: Any) {
        data = MJWindowManager.instance.allWindowList()
        tableView.reloadData()
    }
}

extension MyPopoverViewController:NSTableViewDataSource,NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return data[row]
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let index = tableView.selectedRow
        
        if index >= 0 && index < data.count {
            print("\(data[tableView.selectedRow].windowName)")
            let windowInfo = data[index]
//            MJWindowManager.instance.watch(windowInfo: windowInfo)
            MJWindowManager.instance.activeApplicationAndWathchWindow(windowInfo: windowInfo)

        }
    }
}

extension MyPopoverViewController {
    func initView() {
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func initData() {
        data = MJWindowManager.instance.allWindowList()
        tableView.reloadData()
    }
}
