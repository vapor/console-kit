//
//  ZipSequence.swift
//  Async
//
//  Created by Luke Street on 1/12/19.
//

/// Simplified version of work found here: https://github.com/pointfreeco/swift-overture/blob/master/Sources/Overture/ZipSequence.swift
/// Zips 3 arrays together into a single array
public func zip<A, B, C>(_ a: [A], _ b: [B], _ c: [C]) -> [(A, B, C)] {
    return zip(zip(a, b), c).map { return ($0.0.0, $0.0.1, $0.1) }
}

/// Zips 4 arrays together into a single array
public func zip<A, B, C, D>( _ a: [A], _ b: [B], _ c: [C], _ d: [D]) -> [(A, B, C, D)] {
    return zip(zip(a, b, c), d).map { return ($0.0.0, $0.0.1, $0.0.2, $0.1) }
}

