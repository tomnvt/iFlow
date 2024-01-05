//
//  RoundedCornersShape.swift
//  PianoKeyboard
//
//  Created by Gary Newby on 12/05/2023.
//
import SwiftUI
#if canImport(UIKit)
import UIKit
public typealias PlatformBezierPath = UIBezierPath
public typealias PlatformRect = CGRect
#elseif canImport(AppKit)
import AppKit
public typealias PlatformBezierPath = NSBezierPath
public typealias PlatformRect = NSRect
#endif

public struct RoundedCornersShape: Shape {
#if os(iOS) || targetEnvironment(macCatalyst)
    let radius: CGFloat
#elseif os(macOS)
    let radius: NSSize
#endif

    public init(radius: CGFloat) {
#if os(iOS) || targetEnvironment(macCatalyst)
        self.radius = radius
#elseif os(macOS)
        self.radius = NSSize(width: radius, height: radius)
#endif
    }

    public func path(in rect: PlatformRect) -> Path {
        let path: PlatformBezierPath

#if os(iOS) || targetEnvironment(macCatalyst)
        path = PlatformBezierPath(
            roundedRect: rect,
            cornerRadius: radius
        )
#elseif os(macOS)
        path = PlatformBezierPath(
            roundedRect: rect,
            xRadius: radius.width,
            yRadius: radius.height
        )
#endif

        return Path(path.cgPath)
    }
}
