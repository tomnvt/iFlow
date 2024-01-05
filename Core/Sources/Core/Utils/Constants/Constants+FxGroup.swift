//
//  File.swift
//  
//
//  Created by Tom Novotny on 29.10.2023.
//

extension Constants {
    enum FxGroups {
        static let input: [String] = [
            "AWAY",
            "REVERB",
            "PHASER",
            "FLANGER",
            "VOWEL",
            "STUTTER",
            "AMP",
            "CHORUS",
        ]
        static let looperFx: [[String]] = [
            [
                "FUNKY",
                "FILTER",
                "ARRANGER",
                "BEATVERB",
                "MODULARS",
                "GUITAR",
                "WUB",
                "LEVELIZE",
            ],
            [
                "DUCK",
                "CHEM RING",
                "BUBBLE COMB",
                "LFO",
                "DRUM DUCK",
                "REAKTVERB",
                "DELAY",
                "TRIPLET",
            ],
            [
                "ORPHANS",
                "JAJA",
                "SWITCH UP",
                "CHEM RING",
                "GRESOR",
                "PAN LOOPER",
                "EVIL DIST",
                "WIDEN",
            ],
            [
                "SWEEP STEP",
                "STABS",
                "SLICER",
                "8TH",
                "GUITAR",
                "DETUNE",
                "DELAY",
                "REVERB",
            ],
            [
                "TONALIZER",
                "EVIL DIST",
                "LOOPER",
                "OCTAVISOR",
                "REVERB",
                "FLANGER",
                "COMPLEXER",
                "SEQ FILT",
            ],
            [
                "PAN LOOP",
                "PAN LOOP",
                "PITCH DEL",
                "PLATE DEL",
                "PITCH DEL",
                "FREEZE",
                "VINYLIZER",
                "PITCH DEL",
            ]
        ]
        static let output: [String] = [
            "REVERB",
            "REV TIME",
            "ECHO",
            "ECHO TIME",
            "REPEAT",
            "STOP",
        ]
    }
}
