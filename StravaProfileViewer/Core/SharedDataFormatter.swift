//
//  SharedDataFormatter.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 2/27/26.
//

import Foundation

public final class SharedDataFormatter {
    public static let shared = SharedDataFormatter()
    private init() {}

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yyyy"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    public func date(from string: String) -> Date? {
        dateFormatter.date(from: string)
    }

    public func string(from date: Date) -> String {
        dateFormatter.string(from: date)
    }
}
