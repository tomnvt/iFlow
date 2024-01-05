// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
    /// MIDI Endpoint Information

    import AVFoundation

    /// Information about a MIDI Endpoint
    struct EndpointInfo: Hashable, Codable {
        /// Unique name
        var name = ""

        /// Display name
        var displayName = ""
        /// Model information
        var model = ""

        /// Manufacturer
        var manufacturer = ""

        /// Image?
        var image = ""

        /// Driver Owner
        var driverOwner = ""

        /// MIDIUniqueID
        var midiUniqueID: MIDIUniqueID

        /// MIDIEndpointRef
        var midiEndpointRef: MIDIEndpointRef

        /// MIDIPortRef (this will be set|unset when input|output open|close)
        var midiPortRef: MIDIPortRef?

        /// Equatable
        static func == (lhs: EndpointInfo, rhs: EndpointInfo) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }

        /// Conform to hashable
        /// - Parameter hasher: Hasher to use
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(displayName)
            hasher.combine(model)
            hasher.combine(manufacturer)
            hasher.combine(image)
            hasher.combine(driverOwner)
            hasher.combine(midiUniqueID)
            hasher.combine(midiPortRef)
        }

        /// Initialize this endpoint
        /// - Parameters:
        ///   - name: Unique name
        ///   - displayName: Display Name
        ///   - model: Model description
        ///   - manufacturer: Manufacturer description
        ///   - image: Image
        ///   - driverOwner: Driver owner descriptions
        ///   - midiUniqueID: MIDI Unique ID
        ///   - midiEndpointRef: MIDI Endpoint reference
        ///   - midiPortRef: MIDI Port Reference
        init(name: String,
                    displayName: String,
                    model: String,
                    manufacturer: String,
                    image: String,
                    driverOwner: String,
                    midiUniqueID: MIDIUniqueID,
                    midiEndpointRef: MIDIEndpointRef,
                    midiPortRef: MIDIPortRef? = nil)
        {
            self.name = name
            self.displayName = displayName
            self.model = model
            self.manufacturer = manufacturer
            self.image = image
            self.driverOwner = driverOwner
            self.midiUniqueID = midiUniqueID
            self.midiEndpointRef = midiEndpointRef
            self.midiPortRef = midiPortRef
        }
    }

    extension Collection where Iterator.Element == MIDIEndpointRef {
        var endpointInfos: [EndpointInfo] {
            return map { (element: MIDIEndpointRef) -> EndpointInfo in
                EndpointInfo(
                    name:
                    getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyName),
                    displayName:
                    getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyDisplayName),
                    model:
                    getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyModel),
                    manufacturer:
                    getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyManufacturer),
                    image:
                    getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyImage),
                    driverOwner:
                    getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyDriverOwner),
                    midiUniqueID:
                    getMIDIObjectIntegerProperty(ref: element, property: kMIDIPropertyUniqueID),
                    midiEndpointRef: element
                )
            }
        }
    }

    extension MIDI {
        /// Destinations
        var destinationInfos: [EndpointInfo] {
            return MIDIDestinations().endpointInfos
        }

        /// Inputs
        var inputInfos: [EndpointInfo] {
            return MIDISources().endpointInfos
        }

        /// Virtual Outputs
        var virtualOutputInfos: [EndpointInfo] {
            return virtualOutputs.endpointInfos
        }

        /// Virtual Inputs
        var virtualInputInfos: [EndpointInfo] {
            return virtualInputs.endpointInfos
        }
    }

#endif
