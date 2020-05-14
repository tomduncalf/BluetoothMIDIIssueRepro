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
        sendMidiMessage()
    }
    
    @IBAction func startSendingMessagesTouchDown(_ sender: Any) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.sendMidiMessage()
        }
    }
    
    @IBAction func stopSendingMessagesTouchDown(_ sender: Any) {
        timer?.invalidate()
    }
    
    func sendMidiMessage(_ count: Int = 1) {


//        var builder = MIDIPacketList.Builder(byteSize: count * 3)
//        builder.append(timestamp: 0, data: [0x90, 0x3C, 100])
//        builder.withUnsafeMutableMIDIPacketListPointer { packetList in
//            print ("*** Device before sending: " + String(MIDIGetDestination(midiDestinationIndex)))
//
//            if (MIDIGetDestination(midiDestinationIndex) != 0) {
//                print ("*** Sending MIDI")
//                MIDISend(outputPort, dest, &packetList)
//            }
//        }

            // From https://github.com/chrisjmendez/swift-exercises/blob/548c40ffe13ab826eea620a6075606716be2a12f/Music/MIDI/Playgrounds/SimpleNote.playground/Contents.swift
        var packets: [MIDIPacket] = []
        
        for i in 1...count {
            var packet: MIDIPacket = MIDIPacket()
            packet.timeStamp = 0
            packet.length = 3
            packet.data.0 = 0x90 // Note On event channel 1
            packet.data.1 = 0x3C // Note C3
            packet.data.2 = 100 // Velocity
            packets.append(packet)
        }
        
        var packetList: MIDIPacketList = MIDIPacketList(numPackets: UInt32(count), packet: packets[0])
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

