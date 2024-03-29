// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
/// Common name of MIDI Control number from MIDIByte
///
/// - ModulationWheel: Modulation Control
/// - BreathControl: Breath Control (in MIDI Saxophones for example)
/// - FootControl: Foot Control
/// - Portamento: Portamento effect
/// - DataEntry: Data Entry
/// - MainVolume: Volume (Overall)
/// - Balance
/// - Pan: Stereo Panning
/// - Expression: Expression Pedal
/// - LSB: Least Significant Byte
/// - DamperOnOff: Damper Pedal, also known as Hold or Sustain
/// - PortamentoOnOff: Portamento Toggle
/// - SustenutoOnOff: Sustenuto Toggle
/// - SoftPedalOnOff: Soft Pedal Toggle
/// - DataEntryPlus: Data Entry Addition
/// - DataEntryMinus: Data Entry Subtraction
/// - LocalControlOnOff: Enable local control
/// - AllNotesOff: MIDI Panic
/// - CC# (0, 3, 9, 12-31) Unnamed Continuous Controllers
///
enum MIDIControl: MIDIByte {
    /// Modulation Control
    case modulationWheel = 1
    /// Breath Control (in MIDI Saxophones for example)
    case breathControl = 2
    // ?? 3 ??
    /// Foot Control
    case footControl = 4
    /// Portamento effect
    case portamento = 5
    /// Data Entry
    case dataEntry = 6
    /// Volume (Overall)
    case mainVolume = 7
    /// Balance
    case balance = 8
    // ?? 9 ??
    /// Stereo Panning
    case pan = 10
    /// Expression Pedal
    case expression = 11
    /// Damper Pedal, also known as Hold or Sustain
    case damperOnOff = 64
    /// Portamento Toggle
    case portamentoOnOff = 65
    /// Sustenuto Toggle
    case sustenutoOnOff = 66
    /// Soft Pedal Toggle
    case softPedalOnOff = 67
    /// Sound Variation
    case soundVariation = 70
    /// Resonance
    case resonance = 71
    /// Release Time
    case releaseTime = 72
    /// Attack Time
    case attackTime = 73
    /// Cutoff
    case cutoff = 74
    /// Sound Control 6
    case soundControl6 = 75
    /// Sound Control 7
    case soundControl7 = 76
    /// Sound Control 8
    case soundControl8 = 77
    /// Sound Control 9
    case soundControl9 = 78
    /// Sound Control 10
    case soundControl10 = 79
    /// GP Button 1
    /// Decay, or Roland Tone Level 1
    case gpButton1 = 80
    /// Hi Pass Filter Frequency
    /// Roland Tone Level 1
    /// GP Button 2
    case gpButton2 = 81
    /// Roland Tone Level 3
    /// GP Button 3
    case gpButton3 = 82
    /// Roland Tone Level 4
    /// GP Button 4
    case gpButton4 = 83
    /// Reverb Level
    case reverbLevel = 91
    /// Tremolo Level
    case tremoloLevel = 92
    /// chorus Level
    case chorusLevel = 93
    /// celeste Level
    /// or Detune
    case celesteLevel = 94
    /// phaser Level
    case phaserLevel = 95
    /// Data Entry Addition
    case dataEntryPlus = 96
    /// Data Entry Subtraction
    case dataEntryMinus = 97
    /// Non Registered Parameter Number LSB
    case NrpnLsb = 98
    /// Non Registered Parameter Number MSB
    case NrpnMsb = 99
    /// Registered Parameter Number LSB
    case RpnLsb = 100
    /// Registered Parameter Number MSB
    case RpnMsb = 101
    /// All sounds off
    case allSoundsOff = 120
    /// All controllers off
    case allControllersOff = 121
    /// Enable local control
    case localControlOnOff = 122
    /// MIDI Panic
    case allNotesOff = 123
    /// Omni Mode Off
    case omniModeOff = 124
    /// Omni Mode On
    case omniModeOn = 125
    /// Mono Operation
    case monoOperation = 126
    /// Poly Operation
    case polyOperation = 127
    // Unnamed CC values: (Must be a better way)
    /// Bank Select Most Significant Byte
    /// Continuous Controller Number 0
    case cc0 = 0
    /// Continuous Controller Number 3
    case cc3 = 3
    /// Continuous Controller Number 9
    case cc9 = 9
    /// Effect Control 1
    /// Continuous Controller Number 12
    case cc12 = 12
    /// Effect Control 2
    /// Continuous Controller Number 13
    case cc13 = 13
    /// Continuous Controller Number 14
    case cc14 = 14
    /// Continuous Controller Number 15
    case cc15 = 15
    /// Continuous Controller Number 16
    case cc16 = 16
    /// Continuous Controller Number 17
    case cc17 = 17
    /// Continuous Controller Number 18
    case cc18 = 18
    /// Continuous Controller Number 19
    case cc19 = 19
    /// Continuous Controller Number 20
    case cc20 = 20
    /// Continuous Controller Number 21
    case cc21 = 21
    /// Continuous Controller Number 22
    case cc22 = 22
    /// Continuous Controller Number 23
    case cc23 = 23
    /// Continuous Controller Number 24
    case cc24 = 24
    /// Continuous Controller Number 25
    case cc25 = 25
    /// Continuous Controller Number 26
    case cc26 = 26
    /// Continuous Controller Number 27
    case cc27 = 27
    /// Continuous Controller Number 28
    case cc28 = 28
    /// Continuous Controller Number 29
    case cc29 = 29
    /// Continuous Controller Number 30
    case cc30 = 30
    /// Continuous Controller Number 31
    case cc31 = 31
    /// Bank Select Least Significant Byte
    /// MSB is CC 0
    /// Continuous Controller Number 31
    case cc32 = 32
    /// Modulation Wheel Least Significant Byte
    /// MSB is CC 1
    /// Continuous Controller Number 33
    case modulationWheelLsb = 33
    /// Breath Controller Least Significant Byte
    /// MSB is CC 2
    /// Continuous Controller Number 34
    case breathControllerLsb = 34
    /// MSB is CC 3
    /// ?? 35 ??
    /// Foot Control Least Significant Byte
    /// MSB is CC 4
    /// Continuous Controller Number 35
    case footControlLsb = 35
    /// Portamento Time Least Significant Byte
    /// MSB is CC 5
    /// Continuous Controller Number 37
    case portamentoLsb = 37
    /// Data Entry Least Significant Byte
    /// MSB is CC 6
    /// Continuous Controller Number 38
    case dataEntryLsb = 38
    /// Main Volume Least Significant Byte
    /// MSB is CC 7
    /// Continuous Controller Number 39
    case mainVolumeLsb = 39
    /// Balance Least Significant Byte
    /// MSB is CC 8
    /// Continuous Controller Number 40
    case balanceLsb = 40
    /// Pan Position Least Significant Byte
    /// MSB is CC 10
    /// Continuous Controller Number 42
    case panLsb = 42
    /// Expression Least Significant Byte
    /// MSB is CC 11
    /// Continuous Controller Number 43
    case expressionLsb = 43
    /// Effect Control 1 Least Significant Byte
    /// MSB is CC 12
    /// Roland Protamento on and rate
    /// Continuous Controller Number 44
    case effectControl1Lsb = 44
    /// Effect Control 2 Least Significant Byte
    /// MSB is CC 13
    /// Continuous Controller Number 45
    case effectControl2Lsb = 45
    /// Printable String
    var description: String {
        switch self {
        case .modulationWheel:
            return "Modulation Wheel"
        case .breathControl:
            return "Breath Control"
        case .footControl:
            return "Foot Control"
        case .portamento:
            return "Portamento"
        case .dataEntry:
            return "Data Entry"
        case .mainVolume:
            return "Main Volume"
        case .balance:
            return "Balance"
        case .pan:
            return "Stereo Panning"
        case .expression:
            return "Expression Pedal"
        case .damperOnOff:
            return "Damper Pedal On/Off"
        case .portamentoOnOff:
            return "Portamento On/Off"
        case .sustenutoOnOff:
            return "Sustenuto On/Off"
        case .softPedalOnOff:
            return "Soft Pedal On/Off"
        case .soundVariation:
            return "Sound Variation"
        case .resonance:
            return "Resonance"
        case .releaseTime:
            return "Release Time"
        case .attackTime:
            return "Attack Time"
        case .cutoff:
            return "Cutoff"
        case .soundControl6:
            return "Sound Control 6"
        case .soundControl7:
            return "Sound Control 7"
        case .soundControl8:
            return "Sound Control 8"
        case .soundControl9:
            return "Sound Control 9"
        case .soundControl10:
            return "Sound Control 10"
        case .gpButton1:
            return "GP Button 1"
        case .gpButton2:
            return "GP Button 2"
        case .gpButton3:
            return "GP Button 3"
        case .gpButton4:
            return "GP Button 4"
        case .reverbLevel:
            return "Reverb Level"
        case .tremoloLevel:
            return "Tremolo Level"
        case .chorusLevel:
            return "Chorus Level"
        case .celesteLevel:
            return "Celeste Level or Detune"
        case .phaserLevel:
            return "Phaser Level"
        case .dataEntryPlus:
            return "Data Entry Addition"
        case .dataEntryMinus:
            return "Data Entry Subtraction"
        case .NrpnLsb:
            return "Non-registered Parameter Number LSB"
        case .NrpnMsb:
            return "Non-registered Parameter Number MSB"
        case .RpnLsb:
            return "Registered Parameter Number LSB"
        case .RpnMsb:
            return "Registered Parameter Number MSB"
        case .allSoundsOff:
            return "All Sounds Off"
        case .allControllersOff:
            return "All Controllers Off"
        case .localControlOnOff:
            return "Local Control On/Off"
        case .allNotesOff:
            return "All Notes Off"
        case .omniModeOff:
            return "Omni Mode Off"
        case .omniModeOn:
            return "Omni Mode On"
        case .monoOperation:
            return "Mono Operation"
        case .polyOperation:
            return "Poly Operation"
        case .cc0:
            return "CC #0"
        case .cc3:
            return "CC #3"
        case .cc9:
            return "CC #9"
        case .cc12:
            return "CC #12"
        case .cc13:
            return "CC #13"
        case .cc14:
            return "CC #14"
        case .cc15:
            return "CC #15"
        case .cc16:
            return "CC #16"
        case .cc17:
            return "CC #17"
        case .cc18:
            return "CC #18"
        case .cc19:
            return "CC #19"
        case .cc20:
            return "CC #20"
        case .cc21:
            return "CC #21"
        case .cc22:
            return "CC #22"
        case .cc23:
            return "CC #23"
        case .cc24:
            return "CC #24"
        case .cc25:
            return "CC #25"
        case .cc26:
            return "CC #26"
        case .cc27:
            return "CC #27"
        case .cc28:
            return "CC #28"
        case .cc29:
            return "CC #29"
        case .cc30:
            return "CC #30"
        case .cc31:
            return "CC #31"
        case .cc32:
            return "CC #32"
        case .modulationWheelLsb:
            return "Mod Wheel LSB"
        case .breathControllerLsb:
            return "Breath LSB"
        case .footControlLsb:
            return "Foot LSB"
        case .portamentoLsb:
            return "Portamento LSB"
        case .dataEntryLsb:
            return "Data Entry LSB"
        case .mainVolumeLsb:
            return "Main Volume LSB"
        case .balanceLsb:
            return "Balance LSB"
        case .panLsb:
            return "Pan LSB"
        case .expressionLsb:
            return "Expression LSB"
        case .effectControl1Lsb:
            return "Effect CTRL 1 LSB"
        case .effectControl2Lsb:
            return "Effect CTRL 2 LSB"
        }
    }
}
