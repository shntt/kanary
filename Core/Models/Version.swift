//
//  Version.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/25.
//

import Foundation

struct Version: Comparable, Codable {
    let major: Int
    let minor: Int
    let patch: Int
    
    init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    init?(string: String) {
        let components = string.split(separator: ".")
        guard components.count == 3,
              let major = Int(components[0]),
              let minor = Int(components[1]),
              let patch = Int(components[2]) else {
            return nil
        }
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    var string: String {
        "\(major).\(minor).\(patch)"
    }
    
    static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }
}

struct Release: Codable, Identifiable {
    let id = UUID()
    let tagName: String
    let name: String
    let body: String
    let htmlUrl: String
    let assets: [Asset]
    
    struct Asset: Codable {
        let name: String
        let browserDownloadUrl: String
        
        enum CodingKeys: String, CodingKey {
            case name
            case browserDownloadUrl = "browser_download_url"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name
        case body
        case htmlUrl = "html_url"
        case assets
    }
}
