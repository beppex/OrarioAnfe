//
//  CorsiController.swift
//  OrarioAnfe
//
//  Created by Giuseppe Davi on 16/12/14.
//  Copyright (c) 2014 Giuseppe Davì. All rights reserved.
//

import UIKit

class CorsiController: UIViewController, UITableViewDelegate, UITableViewDataSource, ServerResponseListener
{
    var corsoSelezionato : Dictionary<String,String>? = nil
    var corsi : Array<AnyObject>? = nil

    let app : Application = Application.sharedInstance

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var waiting: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backItem?.title = "Indietro"
        
        corsoSelezionato = app.getCorsoSelezionato()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        
        refresh()
    }

    func onResponse(data: NSData?, error: NSError?) {
        self.waiting.stopAnimating()
        if(data != nil) {
            var newdata = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            
            corsi =  newdata.valueForKey("corsi") as? [AnyObject]
            
            self.tableView.reloadData()
        }
        else  {
            let alert = UIAlertController(
                title: NSLocalizedString("CONNECTION_ERROR", comment: "Errore di rete"),
                message: NSLocalizedString("CONNECTION_ERROR_CORSI", comment: "Non è stato possibile scaricare l'elenco dei corsi'"),
                preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func refresh()
    {
        self.waiting.startAnimating()        
        app.requestCorsi(self);
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return corsi? != nil ? corsi!.count : 0
     }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : CorsoCell = self.tableView.dequeueReusableCellWithIdentifier("corsoCell") as CorsoCell
        
        if(corsi != nil) {
            let corso  = corsi![indexPath.row] as Dictionary<String, String>
            
            cell.accessoryType = corsoSelezionato? != nil && corsoSelezionato!["id_corso"] == corso["id_corso"]
                ? UITableViewCellAccessoryType.Checkmark
                : UITableViewCellAccessoryType.None

            cell.descrizione?.text = corso["corso"]?.lowercaseString.capitalizedString
            cell.codice?.text = corso["codice_corso"]?.lowercaseString
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath index: NSIndexPath)
    {
        self.tableView.reloadData()
        
        let corso = corsi![index.row] as Dictionary<String, String>
        corsoSelezionato = corsoSelezionato? != nil && corsoSelezionato!["id_corso"] == corso["id_corso"] ? nil : corso;
        
        app.resetOrario()
        app.saveCorsoSelezionato(corsoSelezionato)
    }
}

class CorsoCell : UITableViewCell
{
    @IBOutlet weak var descrizione: UILabel!
    @IBOutlet weak var codice: UILabel!
}
