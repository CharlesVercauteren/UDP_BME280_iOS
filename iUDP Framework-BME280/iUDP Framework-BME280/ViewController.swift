//
//  ViewController.swift
//  iUDP Framwork
//
//  Created by Charles Vercauteren on 11/02/2022.
//


import UIKit
import Network

// Arduino (server)
let IP_ADDRESS = "10.89.1.90"
let PORT_SERVER: UInt16 = 2000

var udpClient = iUDPFramework()
var clientReady = false

let GET_TEMPERATURE = "10"
let GET_HUMIDITY = "11"
let GET_PRESSURE = "12"

let interval: TimeInterval = 1

let commands = [GET_TEMPERATURE, GET_HUMIDITY, GET_PRESSURE]
var indx = 0

class ViewController: UIViewController {
    
    @IBOutlet weak var temperatureLbl: UILabel!
    @IBOutlet weak var humidityLbl: UILabel!
    @IBOutlet weak var pressureLbl: UILabel!
    
    let portServer = PORT_SERVER
    var ipAddress = IP_ADDRESS
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        udpClient.delegate = self
        udpClient.setServer(ipAddress: IP_ADDRESS, port: PORT_SERVER)
        udpClient.connect()
        
        // Stuur om de interval s een commando (functie update)
        timer = Timer.scheduledTimer(timeInterval: interval,
                                     target: self,
                                     selector: #selector(update),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func update() {
        // Cirkel door de lijst van commando's
        indx += 1
        if indx >= commands.count { indx = 0 }
        // Stuur commando
        udpClient.sendCommand(command: commands[indx])
    }
}

extension ViewController:UDPMessages {
    
    func connectionReady() {
        clientReady = true
    }
    
    func receivedMessage(message: String) {
        // Splits message in commando en resultaat
        let firstSpace = message.firstIndex(of: " ") ?? message.endIndex
        let command = message[..<firstSpace]
        let result = String(message.suffix(from: firstSpace).dropFirst())
        // Toon het resultaat
        switch command {
        case GET_TEMPERATURE:
            temperatureLbl.text = result + " °C"
        case GET_HUMIDITY:
            humidityLbl.text = result + " %"
        case GET_PRESSURE:
            pressureLbl.text = result + " hPa"
        default:
            temperatureLbl.text = "Fout"
        }
    }
}



