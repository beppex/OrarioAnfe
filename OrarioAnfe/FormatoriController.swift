//
//  FormatoriController.swift
//  OrarioAnfe
//
//  Created by Giuseppe Davi on 16/12/14.
//  Copyright (c) 2014 Giuseppe Davì. All rights reserved.
//

import UIKit

class FormatoriController: UIViewController, UITableViewDelegate, UITableViewDataSource, ServerResponseListener
{
    var formatoreSelezionato : Dictionary<String,String>? = nil
    var formatori : Array<AnyObject>? = nil

    let app : Application = Application.sharedInstance

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var waiting: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        formatoreSelezionato = app.getFormatoreSelezionato()
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
            
            formatori =  newdata.valueForKey("formatori") as? [AnyObject]
            
            self.tableView.reloadData()
        }
        else  {
            let alert = UIAlertController(
                title: NSLocalizedString("CONNECTION_ERROR", comment: "Errore di rete"),
                message: NSLocalizedString("CONNECTION_ERROR_FORMATORI", comment: "Non è stato possibile scaricare l'elenco dei formatori"),
                preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func refresh()
    {
        self.waiting.startAnimating()
        app.requestFormatori(self);
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return formatori? != nil ? formatori!.count : 0
     }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : FormatoreCell = self.tableView.dequeueReusableCellWithIdentifier("formatoreCell") as FormatoreCell
        
        if(formatori != nil) {
            let formatore  = formatori![indexPath.row] as Dictionary<String, String>
            
            cell.accessoryType = formatoreSelezionato? != nil && formatoreSelezionato!["id_docente"] == formatore["id_docente"]
            ? UITableViewCellAccessoryType.Checkmark
            : UITableViewCellAccessoryType.None
 
            cell.formatore?.text = formatore["docente"]?.lowercaseString.capitalizedString
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath index: NSIndexPath)
    {
        self.tableView.reloadData()
        
        let formatore = formatori![index.row] as Dictionary<String, String>
        formatoreSelezionato = formatoreSelezionato? != nil && formatoreSelezionato!["id_docente"] == formatore["id_docente"] ? nil : formatore;
        
        app.resetOrario()
        app.saveFormatoreSelezionato(formatoreSelezionato)
   }
    
    func showError(errorMessage : String!)
    {
        var alert = UIAlertController(title: "Errore", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

class FormatoreCell : UITableViewCell
{
    @IBOutlet weak var formatore: UILabel!
    
}
