//
//  Singletone.swift
//  OrarioAnfe
//
//  Created by Giuseppe Davi on 09/12/14.
//  Copyright (c) 2014 Giuseppe Davì. All rights reserved.
//

import UIKit
import Foundation
//import SQLite

class Application
{
 
    let defaults : NSUserDefaults! = NSUserDefaults.standardUserDefaults()
    var orario : Array<Dictionary<String,String>>?
    
    // singletone instantiation
    
    class var sharedInstance: Application {
        struct Static {
            static var instance: Application?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Application()
            Static.instance?.createDB()
        }
        
        return Static.instance!
    }
    
    // methods
    
    private func createDB()
    {
        var (tables, error) = SD.existingTables()
        if(error == nil) {
            if(find(tables, "orario") == nil) {
                SD.createTable("orario", withColumnNamesAndTypes:
                    ["lastUpdate": SwiftData.DataType.DateVal,
                    "data" : SwiftData.DataType.StringVal,
                    "oraInizio": SwiftData.DataType.StringVal,
                    "oraFine": SwiftData.DataType.StringVal,
                    "idFormatore": SwiftData.DataType.IntVal, "nomeFormatore": SwiftData.DataType.StringVal, "modulo": SwiftData.DataType.StringVal,
                    "idCorso": SwiftData.DataType.IntVal, "titoloCorso": SwiftData.DataType.StringVal, "codiceCorso": SwiftData.DataType.StringVal, "indirizzoCorso": SwiftData.DataType.StringVal,
                    "sedeCorso": SwiftData.DataType.StringVal, "oreCorso": SwiftData.DataType.IntVal, "oreFormatore": SwiftData.DataType.IntVal, "oreModulo": SwiftData.DataType.IntVal]
                )
                SD.createTable("oreCorso", withColumnNamesAndTypes:
                    [   "idCorso": SwiftData.DataType.IntVal, "ore": SwiftData.DataType.IntVal]
                )
                SD.createTable("oreModulo", withColumnNamesAndTypes:
                    [   "idModulo": SwiftData.DataType.IntVal, "ore": SwiftData.DataType.IntVal]
                )
            }
        }
        else {
            println("error in createDB: \(error)")
        }
    }
    
    func getOrario() -> Array<Lezione>! {
        var lezioni : Array<Lezione> = Array<Lezione>()

        var (records, error) = SD.executeQuery("SELECT * FROM orario ORDER by data, oraInizio, oraFine")
        for row in records {
            lezioni.append(lezioneFromDB(row))
        }

        return lezioni
    }
    
    func getVersione() -> String?
    {
        return defaults.objectForKey("versione") as String?
    }
    
    func saveOrarioResponse(reponseData : NSData!)
    {
        var data = NSJSONSerialization.JSONObjectWithData(reponseData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        
        var versione = data.valueForKey("version") as? String
        
        if let orario =  data.valueForKey("orario") as? [Dictionary<String,String>] {
            SD.deleteTable("orario")
            SD.deleteTable("oreCorso")
            SD.deleteTable("oreModulo")
            createDB()
            for day in orario {
                SD.executeChange("INSERT INTO orario (lastUpdate, data, oraInizio, OraFine, idFormatore, nomeFormatore, modulo, idCorso, titoloCorso, codiceCorso, indirizzoCorso, sedeCorso, oreCorso, oreFormatore, oreModulo) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                    withArgs: [day["last_update"]!, day["data"]!, day["fromHour"]!, day["toHour"]!, day["id_docente"]!.toInt()!, day["docente"]!, day["materia"]!, day["id_corso"]!.toInt()!, day["corso"]!, day["codice_corso"]!, day["committente"]!, day["sede"]!, day["ore_corso"]!.toInt()!, day["ore_docente"]!.toInt()!, day["ore_modulo"]!.toInt()! ] )
            }
        }
        
        defaults.setObject(versione, forKey: "versione")
    }
    
    func resetOrario()
    {
        defaults.removeObjectForKey("versione")
    }
    
    func getCorsoSelezionato() -> Dictionary<String,String>?
    {
        return defaults.objectForKey("corsoSelezionato") as Dictionary<String,String>?
    }
    
    func getFormatoreSelezionato() -> Dictionary<String,String>?
    {
        return defaults.objectForKey("formatoreSelezionato") as Dictionary<String,String>?
    }
    
    func saveCorsoSelezionato(corso : Dictionary<String,String>?) -> Void
    {
        if(corso == nil) {
            defaults.removeObjectForKey("corsoSelezionato")
        }
        else {
            defaults.setObject(corso!, forKey: "corsoSelezionato")
        }
    }
    
    func saveFormatoreSelezionato(formatore : Dictionary<String,String>?) -> Void
    {
        if(formatore == nil) {
            defaults.removeObjectForKey("formatoreSelezionato")
        }
        else {
            defaults.setObject(formatore!, forKey: "formatoreSelezionato")
        }
    }
    
    func requestOrario(listener : ServerResponseListener!)
    {
        var params = Array<String>()
        
        let corsoSelezionato = defaults.objectForKey("corsoSelezionato") as Dictionary<String, String>?
        let formatoreSelezionato = defaults.objectForKey("formatoreSelezionato") as Dictionary<String, String>?
        if(corsoSelezionato? != nil || formatoreSelezionato? != nil) {
            params.append(corsoSelezionato? != nil ? corsoSelezionato!["id_corso"]! : "-1")
            params.append(formatoreSelezionato? != nil ? formatoreSelezionato!["id_docente"]! : "-1")
            self.callServer("getOrario", params : params, listener: listener)
        }
    }
    
    func requestCorsi(listener : ServerResponseListener!)
    {
        callServer("getCorsi", params : [], listener: listener)
    }
    
    func requestFormatori(listener : ServerResponseListener!)
    {
        callServer("getFormatori", params : [], listener: listener)
    }
    
    func getToday() -> NSDate!
    {
        return NSDate()
    }

    func getTomorrow() -> NSDate!
    {
        return getNextDate(getToday())
    }
    
    func getYesterday() -> NSDate!
    {
        return getPreviousDate(getToday())
    }

    func getPreviousDate(day : NSDate!) -> NSDate!
    {
        return day.dateByAddingTimeInterval(-60*60*24)
    }

    func getNextDate(day : NSDate!) -> NSDate!
    {
        return day.dateByAddingTimeInterval(60*60*24)
    }
    
    func getFirstLezione() -> (lezione: Lezione!, data: NSDate!)?
    {
        var (rows, error) = SD.executeQuery("SELECT * FROM orario  ORDER by data LIMIT 1")
        for row in rows {
            let lezione: Lezione = lezioneFromDB(row)
            
            var df = NSDateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let data = df.dateFromString(lezione.data!)
            
            return (lezione, data)
        }
        
        return nil
    }
    
    func getLastLezione() -> (lezione: Lezione!, data: NSDate!)?
    {
        var (rows, error) = SD.executeQuery("SELECT * FROM orario  ORDER by data DESC LIMIT 1")
        for row in rows {
            let lezione: Lezione = lezioneFromDB(row)
            
            var df = NSDateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let data = df.dateFromString(lezione.data!)
            
            return (lezione, data)
        }
        
        return nil
    }
    
    
    func getLezione(date : NSDate!) -> Array<Lezione>?
    {
        var lezioni : Array<Lezione> = Array<Lezione>()
       
        var df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dataString = df.stringFromDate(date)
 
        var (rows, error) = SD.executeQuery("SELECT * FROM orario  WHERE data = ? ORDER by oraInizio, oraFine", withArgs: [dataString])
        for row in rows {
            lezioni.append(lezioneFromDB(row))
        }
        return lezioni
    }
    
    func parseOrarioDate(dateString : String!) -> NSDate?
    {
        var df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        return df.dateFromString(dateString)
    }
    
    func formatOrarioDate(data : NSDate!) -> String?
    {
        var df = NSDateFormatter()
        df.dateFormat = "dd-MM-yy"
        
        return df.stringFromDate(data)
    }
    
    func isSunday(day : NSDate!) -> Bool
    {
        var calendar = NSCalendar.currentCalendar()
        var components = calendar.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: day!)
        
        return components.weekday == 1
    }
    
    func isEqualsIgnoreTimeToDate(date1 : NSDate!, date2 : NSDate!) -> Bool
    {
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        let components1 : NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay, fromDate: date1)
        let components2 : NSDateComponents = calendar.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay, fromDate: date2)
        
        return ((components1.year == components2.year) && (components1.month == components2.month) && (components1.day == components2.day));
    }
    
    func showUIAlertWithMessage(message : String, title : String) {
        let alert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
    // private methods 
    
    private func callServer(service : String, params : Array<String>, listener : ServerResponseListener ) -> Void
    {
        var url : String = "http://pa2.anfe.it/orario/index.php/android/" + service + "/"
        
        for param in params {
            url += param + "/"
        }
        //println(url)
        
        var urlRequest = NSURL(string: url)
        var request = NSURLRequest(URL: urlRequest!)
        
        var queue : NSOperationQueue = NSOperationQueue.mainQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue : queue, completionHandler : {
            (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            var jsonData : NSDictionary? = nil
            
            listener.onResponse(data?, error: error?)
        })
    }
    
    private func lezioneFromDB(row: SwiftData.SDRow) -> Lezione!
    {
        return Lezione(
            lastUpdate: row["lastUpdate"]!.asDate()!,
            data: row["data"]!.asString()!,
            oraInizio: row["oraInizio"]!.asString()!,
            oraFine: row["oraFine"]!.asString()!,
            idFormatore: row["idFormatore"]!.asInt()!,
            nomeFormatore: row["nomeFormatore"]!.asString()!,
            modulo: row["modulo"]!.asString()!,
            idCorso: row["idCorso"]!.asInt()!,
            titoloCorso: row["titoloCorso"]!.asString()!,
            codiceCorso: row["codiceCorso"]!.asString()!,
            indirizzoCorso: row["indirizzoCorso"]!.asString()!,
            sedeCorso: row["sedeCorso"]!.asString()!,
            oreCorso: row["oreCorso"]!.asInt()!,
            oreFormatore: row["oreFormatore"]!.asInt()!,
            oreModulo: row["oreModulo"]!.asInt()!)
    }
}


protocol ServerResponseListener
{
    func onResponse(data : NSData?, error : NSError? );
}

