//
//  PolylineDecoder.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 3/19/26.
//

import Foundation
import CoreLocation

// MARK: - Encoded Polyline Decoder

struct PolylineDecoder {

    /// Decodes a Google Encoded Polyline string into an array of CLLocationCoordinate2D.
    /// - Parameter encoded: The encoded polyline string from the Strava Segment API.
    /// - Returns: An array of coordinates, or an empty array if decoding fails.
    static func decode(_ encoded: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        var index = encoded.startIndex
        var lat: Int = 0
        var lng: Int = 0

        while index < encoded.endIndex {
            // Decode latitude delta
            guard let latDelta = decodeNextValue(encoded: encoded, index: &index) else { break }
            lat += latDelta

            // Decode longitude delta
            guard let lngDelta = decodeNextValue(encoded: encoded, index: &index) else { break }
            lng += lngDelta

            let coordinate = CLLocationCoordinate2D(
                latitude:  Double(lat) / 1e5,
                longitude: Double(lng) / 1e5
            )
            coordinates.append(coordinate)
        }

        return coordinates
    }

    // MARK: - Private

    /// Reads the next encoded integer delta from the string, advancing `index` in place.
    private static func decodeNextValue(encoded: String, index: inout String.Index) -> Int? {
        var result = 0
        var shift  = 0

        repeat {
            guard index < encoded.endIndex else { return nil }

            let asciiValue = Int(encoded[index].asciiValue ?? 0) - 63
            index = encoded.index(after: index)

            result |= (asciiValue & 0x1F) << shift
            shift  += 5

            // Continue while the "more data" bit (0x20) is set
            guard asciiValue >= 0x20 else { break }
        } while true

        // Zig-zag decode: odd values are negative
        return (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
    }
}

// MARK: - String Extension (convenience)

extension String {

    /// Decodes this string as a Google Encoded Polyline.
    /// - Returns: An array of `CLLocationCoordinate2D`.
    func decodedPolyline() -> [CLLocationCoordinate2D] {
        PolylineDecoder.decode(self)
    }
}

// MARK: - Usage Examples

/*

 // 1. Using the static decoder directly
 let encoded = "}g|eFnpqjVl@En@Md@HbAd@..."
 let coords = PolylineDecoder.decode(encoded)

 for coord in coords {
     print("lat: \(coord.latitude), lng: \(coord.longitude)")
 }

 // 2. Using the String extension
 let coords2 = encoded.decodedPolyline()

 // 3. Feeding into a MKPolyline (MapKit)
 import MapKit

 let mkPolyline = MKPolyline(coordinates: coords, count: coords.count)
 mapView.addOverlay(mkPolyline)

 // 4. Feeding into a GMSPolyline (Google Maps SDK)
 // let path = GMSMutablePath()
 // coords.forEach { path.addLatitude($0.latitude, longitude: $0.longitude) }
 // let gmsPolyline = GMSPolyline(path: path)

*/
