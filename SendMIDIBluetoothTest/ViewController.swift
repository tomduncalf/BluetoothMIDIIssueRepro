//
//  ViewController.swift
//  SendMIDIBluetoothTest
//
//  Created by Tom Duncalf on 13/05/2020.
//  Copyright © 2020 td. All rights reserved.
//

import UIKit
import CoreMIDI

class ViewController: UIViewController {
    var midiDestinationIndex = 1
    
    var midiClient: MIDIClientRef = 0
    public var outputPort = MIDIPortRef()
    var dest: MIDIEndpointRef = 0
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    let midiNotifyProc: MIDINotifyProc = { message, refCon in
        print("*** MIDI notify, messageID = \(message.pointee.messageID.rawValue)")
    }
    
    @IBAction func setupTouchDown(_ sender: Any) {
        MIDIClientCreate("MidiTestClient" as CFString, midiNotifyProc, nil, &midiClient);
        MIDIOutputPortCreate(midiClient, "MidiTest_OutPort" as CFString, &outputPort);
        
        print ("*** Number of destinations: " + String(MIDIGetNumberOfDestinations()))
        dest = MIDIGetDestination(midiDestinationIndex) // Change this if your Bluetooth MIDI device is not at index 1
        print ("*** Using device: " + getMIDIObjectStringProperty(ref: dest, property: kMIDIPropertyDisplayName))
    }
    
    @IBAction func sendMessageTouchDown(_ sender: Any) {
        sendNoteOn()
    }

    @IBAction func startSendingMessages1HzTouchDown(_ sender: Any) {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
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
    
    @IBAction func sendSysexTouchDown(_ sender: Any) {
        sendSysex()
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
    
    func sendSysex() {
        // From https://github.com/chrisjmendez/swift-exercises/blob/548c40ffe13ab826eea620a6075606716be2a12f/Music/MIDI/Playgrounds/SimpleNote.playground/Contents.swift
        var packet1: MIDIPacket = MIDIPacket()
            packet1.timeStamp = 0
            packet1.length = 11

            packet1.data.0 = 0xF0
            packet1.data.1 = 0x00
            packet1.data.2 = 0x21
            packet1.data.3 = 0x10
            packet1.data.4 = 0x77
            packet1.data.5 = 0x2F
            packet1.data.6 = 0x01
            packet1.data.7 = 0x03
            packet1.data.8 = 0x00
            packet1.data.9 = 0x63
            packet1.data.10 = 0xF7
        
        var packetList: MIDIPacketList = MIDIPacketList(numPackets: 1, packet: packet1)

        print ("*** Device before sending: " + String(MIDIGetDestination(midiDestinationIndex)))
        
        if (MIDIGetDestination(midiDestinationIndex) != 0) {
            print ("*** Sending MIDI")
            MIDISend(outputPort, dest, &packetList)
        }
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

