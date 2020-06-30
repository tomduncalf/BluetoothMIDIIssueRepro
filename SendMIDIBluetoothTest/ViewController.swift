//
//  ViewController.swift
//  SendMIDIBluetoothTest
//
//  Created by Tom Duncalf on 13/05/2020.
//  Copyright © 2020 td. All rights reserved.
//

import UIKit
import CoreMIDI
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {
    var midiDestinationIndex = 1
    
    var midiClient: MIDIClientRef = 0
    public var inputPort = MIDIPortRef()
    public var outputPort = MIDIPortRef()
    var dest: MIDIEndpointRef = 0
    var timer: Timer?
    
    var cbManager: CBCentralManager?
    var p: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    let midiNotifyProc: MIDINotifyProc = { message, refCon in
        print("*** MIDI notify, messageID = \(message.pointee.messageID.rawValue)")
    }
    
    let midiReadProc: MIDIReadProc = { messageList, readProcRefCon, refCon in
        print ("MSG: \(messageList.pointee.numPackets)")
    }

    @IBAction func midiRestart(_ sender: Any) {
        MIDIRestart()
    }
    
    @IBAction func setupTouchDown(_ sender: Any) {
        MIDIClientCreate("MidiTestClient" as CFString, midiNotifyProc, nil, &midiClient);
        MIDIOutputPortCreate(midiClient, "MidiTest_OutPort" as CFString, &outputPort);
        MIDIInputPortCreate(midiClient, "MidiTest_Input" as CFString, midiReadProc, nil, &inputPort)
        
        print ("*** MIDI session setup")
    }
    
    @IBAction func setupMidiConnection(_ sender: Any) {
        print ("*** Number of destinations: " + String(MIDIGetNumberOfDestinations()))
        dest = MIDIGetDestination(MIDIGetNumberOfDestinations() - 1) // Change this if your Bluetooth MIDI device is not at index 1
        print ("*** Using device: " + getMIDIObjectStringProperty(ref: dest, property: kMIDIPropertyDisplayName))
        
        let source = MIDIGetSource(MIDIGetNumberOfDestinations() - 1) // Change this if your Bluetooth MIDI device is not at index 1
        let s = MIDIPortConnectSource(inputPort, source, nil)
        
        for i in 0..<MIDIGetNumberOfDestinations() {
            let thisDest = MIDIGetDestination(i)
            print ("Destination \(i): \(getMIDIObjectStringProperty(ref: thisDest, property: kMIDIPropertyDisplayName))")
        }
    }
    
    @IBAction func sendMessageTouchDown(_ sender: Any) {
        sendNoteOn()
    }

    @IBAction func startSendingMessages1HzTouchDown(_ sender: Any) {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.sendNoteOn()
        }
    }
    
    @IBAction func startSendingMessages5HzTouchDown(_ sender: Any) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.sendNoteOn()
        }
    }
    
    @IBAction func startSendingMessages2HzTouchDown(_ sender: Any) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            self.sendNoteOn()
        }
    }
    
    @IBAction func stopSendingMessagesTouchDown(_ sender: Any) {
        timer?.invalidate()
    }
    
    func sendNoteOn() {
        // From https://github.com/chrisjmendez/swift-exercises/blob/548c40ffe13ab826eea620a6075606716be2a12f/Music/MIDI/Playgrounds/SimpleNote.playground/Contents.swift
        var packet1: MIDIPacket = MIDIPacket()
            packet1.timeStamp = 0
            packet1.length = 3
            packet1.data.0 = 0x90 + 0 // Note On event channel 1
            packet1.data.1 = 0x3C // Note C3
            packet1.data.2 = 100 // Velocity
        var packetList: MIDIPacketList = MIDIPacketList(numPackets: 1, packet: packet1)

        print ("*** Device before sending: " + String(MIDIGetDestination(midiDestinationIndex)))
        
        if (MIDIGetDestination(midiDestinationIndex) != 0) {
            print ("*** Sending MIDI")
            MIDISend(outputPort, dest, &packetList)
        }
    }
    
    @IBAction func scan(_ sender: Any) {
        cbManager = CBCentralManager()
        cbManager?.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("State \(central.state)")
        cbManager?.scanForPeripherals(withServices: [CBUUID(string: "03B80E5A-EDE8-4B33-A751-6CE34EC4C700")], options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name)")
        p = peripheral
        cbManager?.connect(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print ("Disconnected: \(peripheral.name)")
    }
    
    // Copied from AudioKit
    internal func getMIDIObjectStringProperty(ref: MIDIObjectRef, property: CFString) -> String {
        var string: Unmanaged<CFString>?
        MIDIObjectGetStringProperty(ref, property, &string)
        if let returnString = string?.takeRetainedValue() {
            return returnString as String
        } else {
            return ""
        }
    }
}

