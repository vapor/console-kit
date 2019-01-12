//
//  KeyPath.swift
//  Async
//
//  Created by Luke Street on 1/12/19.
//


/// Produces a getter function for a given key path. Useful for composing property access with functions.
///
///     get(\String.count)
///     // (String) -> Int
///
/// - Parameter keyPath: A key path.
/// - Returns: A getter function.
/// - Note: First defined here: https://github.com/pointfreeco/swift-overture/blob/master/Sources/Overture/KeyPath.swift
public func get<Root, Value>(_ keyPath: KeyPath<Root, Value>) -> (Root) -> Value {
    return { root in root[keyPath: keyPath] }
}
