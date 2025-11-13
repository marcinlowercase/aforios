//
//  HelperFunctions.swift
//  a
//
//  Created by Tom on 11/13/25.
//

import Foundation

func domain(from urlString: String) -> String? {
    guard let url = URL(string: urlString), let host = url.host else {
        return nil
    }
    // Remove "www." prefix if it exists
    return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
}
