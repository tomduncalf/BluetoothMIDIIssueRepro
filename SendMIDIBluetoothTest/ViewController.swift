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
    private var realSuperView: UIView?
    
    var midiClient: MIDIClientRef = 0;
    public var outputPort = MIDIPortRef()
    var dest: MIDIEndpointRef = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func setupTouchDown(_ sender: Any) {
        MIDIClientCreate("MidiTestClient" as CFString, nil, nil, &midiClient);
        MIDIOutputPortCreate(midiClient, "MidiTest_OutPort" as CFString, &outputPort);
        
        print (MIDIGetNumberOfDestinations())
        dest = MIDIGetDestination(1) // Change this if your Bluetooth MIDI device is not at index 1
        print ("Using device: " + getMIDIObjectStringProperty(ref: dest, property: kMIDIPropertyDisplayName))
    }
    
    @IBAction func testTouchDown(_ sender: Any) {
        // From https://github.com/chrisjmendez/swift-exercises/blob/548c40ffe13ab826eea620a6075606716be2a12f/Music/MIDI/Playgrounds/SimpleNote.playground/Contents.swift
        var packet1: MIDIPacket = MIDIPacket();
            packet1.timeStamp = 0;
            packet1.length = 3;
            packet1.data.0 = 0x90 + 0; // Note On event channel 1
            packet1.data.1 = 0x3C; // Note C3
            packet1.data.2 = 100; // Velocity
        var packetList: MIDIPacketList = MIDIPacketList(numPackets: 1, packet: packet1);

        print ("Sending")
        MIDISend(outputPort, dest, &packetList)
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

