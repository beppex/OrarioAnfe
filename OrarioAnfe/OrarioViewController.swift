//
//  ViewController.swift
//  OrarioAnfe
//
//  Created by Giuseppe Davi on 09/12/14.
//  Copyright (c) 2014 Giuseppe Davì. All rights reserved.
//

import UIKit

class OrarioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, ServerResponseListener
{
    var versione : String? = nil
    var corsoSelezionato : Dictionary<String,String>? = nil
    var formatoreSelezionato : Dictionary<String,String>? = nil
    var orario : Array<Lezione>? = nil
    var defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var todayIndex : Int? = nil

    let transitionManager = TransitionManager()
    let app : Application! = Application.sharedInstance
    
    @IBOutlet weak var descrizioneFiltro: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var waiting: UIActivityIndicatorView!
    @IBOutlet weak var refreshBtn: UIBarButtonItem!
    @IBOutlet weak var setting: UIBarButtonItem!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.layoutMargins = UIEdgeInsetsZero
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(false)
        
        versione = app.getVersione()
        corsoSelezionato = app.getCorsoSelezionato()
        formatoreSelezionato = app.getFormatoreSelezionato()
        
        if(versione != nil) {
            orario = app.getOrario()
            tableView.reloadData()
        }
        else if(corsoSelezionato? != nil || formatoreSelezionato? != nil) {
            reload()
        }
        else {
            let storyBoard = UIStoryboard(name : "Main", bundle : nil)
            let viewController = storyBoard.instantiateViewControllerWithIdentifier("setting") as SettingController
            let navController = UINavigationController(rootViewController: viewController)
            self.navigationController?.presentViewController(navController, animated: true, completion: nil)
        }
        
        let descrizioneCorso = corsoSelezionato? != nil ? corsoSelezionato!["corso"]?.lowercaseString.capitalizedString : nil
        let descrizioneFormatore = formatoreSelezionato? != nil ? formatoreSelezionato!["docente"]?.lowercaseString.capitalizedString : nil
        
        descrizioneFiltro.text = descrizioneCorso? == nil ? "" : descrizioneCorso!
        descrizioneFiltro.text = descrizioneFiltro.text! + (corsoSelezionato? != nil && formatoreSelezionato? != nil ? " - " : "")
        descrizioneFiltro.text = descrizioneFiltro.text! + (descrizioneFormatore? == nil ? "" : descrizioneFormatore!)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        gotoToday()
    }
    
    func onResponse(data: NSData?, error: NSError?)
    {
        waiting.stopAnimating()
        refreshBtn.enabled = true
        setting.enabled = true
        
        if(data != nil) {
            app.saveOrarioResponse(data)
            
            orario = app.getOrario()
            versione = app.getVersione()
            
            tableView.reloadData()
        }
        else {
            app.resetOrario()
            
            let alert = UIAlertController(
                title: NSLocalizedString("CONNECTION_ERROR", comment: "Errore di rete"),
                message: NSLocalizedString("CONNECTION_ERROR_ORARIO", comment: "Non è stato possibile scaricare l'orario"),
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))

            self.presentViewController(alert, animated: true, completion: nil)
        }
        refreshBtn.enabled = true
    }

    func reload()
    {
        waiting.startAnimating()
        setting.enabled = false
        refreshBtn.enabled = false
        app.requestOrario(self)
    }
 
    @IBAction func refresh(sender: AnyObject)
    {
        reload()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        println("prepareForSegue: \(segue.identifier)")
        
        if(segue.identifier == "showOggi") {
            let vc = segue.destinationViewController as GiornoViewController
            vc.giorno = app.getToday()
        }
        else if(segue.identifier == "showDomani") {
            let vc = segue.destinationViewController as GiornoViewController
            vc.giorno = app.getTomorrow()
        }
        else if(segue.identifier == "showDay") {
            let index : NSIndexPath = self.tableView.indexPathForSelectedRow()!
            let lezione = orario![index.row] as Lezione
            
            let vc = segue.destinationViewController as GiornoViewController
            var df = NSDateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            vc.giorno = df.dateFromString(lezione.data)
            vc.transitioningDelegate = self.transitionManager
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return orario? != nil ? orario!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : TableCellAdapter = self.tableView.dequeueReusableCellWithIdentifier("customCell") as TableCellAdapter
        cell.layoutMargins = UIEdgeInsetsZero

        if(orario != nil) {
            let lezione = orario![indexPath.row] as Lezione
            
            cell.loadItems(lezione)

            cell.docente.hidden = formatoreSelezionato != nil
            cell.corso.hidden = corsoSelezionato != nil
        }
        
        return cell;
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }

    private func gotoToday()
    {
        if(orario? != nil && orario!.count > 0) {
            findTodayIndex()
            if let dayIndex = todayIndex != nil ? todayIndex : orario!.count - 1 {
                let dayIndexPath = NSIndexPath(forItem: dayIndex, inSection: 0)
                tableView.cellForRowAtIndexPath(dayIndexPath)
                tableView.scrollToRowAtIndexPath(dayIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
            }
        }
    }

    private func findTodayIndex()
    {
        todayIndex = 0
        for lezione in orario! {
            if(lezione.isNext()) {
                return
            }
            todayIndex!++
        }
        todayIndex = nil
    }
}

