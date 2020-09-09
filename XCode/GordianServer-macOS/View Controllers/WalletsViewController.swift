//
//  WalletsViewController.swift
//  GordianServer-macOS
//
//  Created by Peter on 9/3/20.
//  Copyright © 2020 Peter. All rights reserved.
//

import Cocoa

class WalletsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var window: NSWindow?
    var wallets = [String]()
    var selectedWallet = ""
    var env = [String:String]()
    var index = 0
    var chain = ""
    let d = Defaults()
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .reloadWallets, object: nil)
        loadTable()
    }
    
    override func viewDidAppear() {
        window = self.view.window!
        self.view.window?.title = "Wallets \(chain)"
    }
    
    @objc func reload() {
        loadTable()
    }
    
    private func loadTable() {
        wallets.removeAll()
        index = 0
        setEnv()
        getWallets()
    }
    
    enum CellIdentifiers {
        static let WalletNameCell = "WalletNameCellID"
        static let WalletLoadedCell = "WalletLoadedCellID"
    }
    
    func setEnv() {
        env = ["BINARY_NAME":d.existingBinary(),"VERSION":d.existingPrefix(),"PREFIX":d.existingPrefix(),"DATADIR":d.dataDir(), "CHAIN":chain, "COMMAND":"listwalletdir"]
        #if DEBUG
        print("env = \(env)")
        #endif
    }
    
    private func getWallets() {
        runScript(script: .rpc, env: env, args: [""]) { [weak self] (ws) in
            if ws != nil {
                for (i, wallet) in ws!.enumerated() {
                    let dict = wallet as? NSDictionary ?? [:]
                    var name = dict["name"] as? String ?? ""
                    if name == "" {
                        name = "Default wallet"
                    }
                    self?.wallets.append(name)
                    if i + 1 == ws!.count {
                        DispatchQueue.main.async { [weak self] in
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return wallets.count
    }
        
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        let wallet = wallets[row]
        
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameColumn") {
            text = wallet
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "WalletNameCellID"), owner: self) as! NSTableCellView
            cell.textField?.stringValue = text
            cell.imageView?.image = NSImage(imageLiteralResourceName: "btccore-copy.png")
            return cell
            
        } else {
            return nil
        }
        
    }
    
//    func tableViewSelectionDidChange(_ notification: Notification) {
//
//    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        guard tableView.selectedRow >= 0 else { return }
        selectedWallet = wallets[tableView.selectedRow]
        goToDetail()
    }
    
    private func goToDetail() {
        DispatchQueue.main.async { [weak self] in
            self?.performSegue(withIdentifier: "segueToWalletDetail", sender: self)
        }
    }
    
    private func runScript(script: SCRIPT, env: [String:String], args: [String], completion: @escaping ((NSArray?)) -> Void) {
        #if DEBUG
        print("script: \(script.rawValue)")
        #endif
        let resource = script.rawValue
        guard let path = Bundle.main.path(forResource: resource, ofType: "command") else {
            return
        }
        let stdOut = Pipe()
        let stdErr = Pipe()
        let task = Process()
        task.launchPath = path
        task.environment = env
        task.arguments = args
        task.standardOutput = stdOut
        task.standardError = stdErr
        task.launch()
        task.waitUntilExit()
        let data = stdOut.fileHandleForReading.readDataToEndOfFile()
        let errorData = stdErr.fileHandleForReading.readDataToEndOfFile()
        var errorMessage = ""
        if let errorOutput = String(data: errorData, encoding: .utf8) {
            if errorOutput != "" {
                errorMessage += errorOutput
                setSimpleAlert(message: "Error", info: errorMessage, buttonLabel: "OK")
                completion((nil))
            }
        }
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                if let wallets = dict["wallets"] as? NSArray {
                    completion((wallets))
                } else {
                    completion((nil))
                }
            }
        } catch {
            completion((nil))
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToWalletDetail" {
            if let vc = segue.destinationController as? WalletDetail {
                vc.name = selectedWallet
            }
        }
    }
    
}
