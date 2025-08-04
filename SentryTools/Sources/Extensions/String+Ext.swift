//
//  String+Ext.swift
//  SentryTools
//
//  Created by Michael Eid on 8/1/25.
//


extension String {
    public func deletingPrefix(_ prefix: String) -> String {
      guard self.hasPrefix(prefix) else { return self }
      return String(dropFirst(prefix.count))
    }
}
