////
// ScrimUtils.swift
// scrim

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// © 2025 Charles Choi.

import Foundation

enum ScrimUtils {
}

extension ScrimUtils {
    static public func findFirstQueryItem(components: URLComponents, key: String="file") -> String? {
        guard let queryItems = components.queryItems else {
            return nil
        }

        let filteredItems = queryItems.filter { $0.name ==  key}
            
        if filteredItems.count > 0 {
            let firstItem = filteredItems[0]
            return firstItem.value
        } else {
            return nil
        }
    }
        
    
    
    static public func scrimIsFrame(components: URLComponents) -> Bool {
        guard let queryItems = components.queryItems else {
            return false
        }
        
        let filteredItems = queryItems.filter { $0.name == "frame" }
        
        return (filteredItems.count > 0)
    }
}
