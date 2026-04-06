//
//  SegmentViewData+Mocks.swift
//  StravaProfileViewer
//
//  Created by Yuchen Nie on 3/19/26.
//

import Foundation
import CoreLocation

extension SegmentViewData {
    public static func createMock(
        id: Int = 20201,
        name: String = "Test Climb",
        climbCategory: ClimbCategory = .category4,
        avgGrade: Double = 5.0,
        elevationGain: Double = 150.0,
        distance: Double = 3000.0,
        distanceText: String = "3.00 km",
        elevationText: String = "150 m",
        gradeText: String = "5.0%",
        starred: Bool = false,
        startCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.4000, longitude: -122.1500),
        endCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.4050, longitude: -122.1450),
        polylineString: String = "}g|eFnpqjVl@En@Md@HbAd@d@^h@Xx@VbARjBDh@OPQf@w@d@k@XKXDFPH\\EbGTAV@v@|@NTNb@?XOb@cAxAWLuE@eAFMBoAv@eBt@q@b@}@tAeAt@i@dACAFZj@dB?~@[h@MbAVn@b@b@\\d@Eh@Qb@_@d@eB|@c@h@WfBK|AMpA?VF\\\\t@f@t@h@j@|@b@hCb@b@XTd@Bl@GtA?jALALp@Tr@RXd@Rx@Pn@^Zh@Tx@Zf@`@FTCzDy@f@Yx@m@n@Op@VJr@"
    ) -> Self {
        return SegmentViewData(
            id: id,
            name: name,
            climbCategory: climbCategory,
            avgGrade: avgGrade,
            elevationGain: elevationGain,
            distance: distance,
            distanceText: distanceText,
            elevationText: elevationText,
            gradeText: gradeText,
            starred: starred,
            startCoordinate: startCoordinate,
            endCoordinate: endCoordinate,
            polylineString: polylineString
        )
    }
}

extension SegmentViewData {
    public static func createMocks() -> [Self] {
        // All segments are in the San Francisco Peninsula / South Bay area
        // Center point approximately: 37.40°N, 122.15°W (near Palo Alto/Woodside)
        return [
            .createMock(
                id: 20201,
                name: "Old La Honda Road",
                climbCategory: .hc,
                avgGrade: 7.0,
                elevationGain: 395.0,
                distance: 5100.0,
                distanceText: "5.10 km",
                elevationText: "395 m",
                gradeText: "7.0%",
                starred: true,
                startCoordinate: CLLocationCoordinate2D(latitude: 37.4001, longitude: -122.1872),
                endCoordinate: CLLocationCoordinate2D(latitude: 37.4234, longitude: -122.2156),
                polylineString: "ws{eFhisjVAVAVCZAXCXCVE\\E\\EZEXGZGZGXI\\I\\IZK\\K\\K\\M\\M\\M\\O\\O\\O\\O\\Q\\Q\\Q\\S\\S\\S\\U\\U\\U\\W\\W\\W\\Y\\Y\\[\\[\\[\\]\\]\\]\\]\\]\\]"
            ),
            .createMock(
                id: 20202,
                name: "Kings Mountain Road",
                climbCategory: .category3,
                avgGrade: 6.5,
                elevationGain: 480.0,
                distance: 7400.0,
                distanceText: "7.40 km",
                elevationText: "480 m",
                gradeText: "6.5%",
                starred: true,
                startCoordinate: CLLocationCoordinate2D(latitude: 37.4234, longitude: -122.2156),
                endCoordinate: CLLocationCoordinate2D(latitude: 37.4489, longitude: -122.2645),
                polylineString: "qe}eF`btjVY\\Y\\[\\[\\[\\]\\]\\]\\]\\]\\]\\]\\]\\_\\a\\a\\a\\a\\a\\c\\c\\c\\c\\c\\e\\e\\e\\e\\g\\g\\g\\g\\i\\i\\i\\k\\k\\k\\k\\m\\m\\m\\o\\o\\o\\q\\q\\q\\s\\s\\s\\u\\u\\w\\w\\w\\y\\y\\y\\y\\{\\{\\{\\}\\}\\}\\A~@A~@C~@C~@"
                ),
            .createMock(
                id: 20203,
                name: "West Alpine Road",
                climbCategory: .category4,
                avgGrade: 5.5,
                elevationGain: 200.0,
                distance: 3600.0,
                distanceText: "3.60 km",
                elevationText: "200 m",
                gradeText: "5.5%",
                starred: false,
                startCoordinate: CLLocationCoordinate2D(latitude: 37.3890, longitude: -122.2412),
                endCoordinate: CLLocationCoordinate2D(latitude: 37.3998, longitude: -122.2687),
                polylineString: "sq|eFpxujVGZGZIZIZIZKZK\\K\\M\\M\\M\\O\\O\\O\\Q\\Q\\Q\\S\\S\\S\\U\\U\\U\\W\\W\\Y\\Y\\[\\[\\[\\]\\]\\]\\]\\]\\]\\]\\]"
            ),
            .createMock(
                id: 20204,
                name: "Skyline to Page Mill",
                climbCategory: .category2,
                avgGrade: 4.8,
                elevationGain: 290.0,
                distance: 6000.0,
                distanceText: "6.00 km",
                elevationText: "290 m",
                gradeText: "4.8%",
                starred: true,
                startCoordinate: CLLocationCoordinate2D(latitude: 37.3734, longitude: -122.1623),
                endCoordinate: CLLocationCoordinate2D(latitude: 37.3890, longitude: -122.2412),
                polylineString: "ua|eFbhqjVEXEXGXGZGZGZIZIZIZKZK\\K\\K\\M\\M\\M\\O\\O\\O\\Q\\Q\\Q\\S\\S\\S\\U\\U\\W\\W\\W\\Y\\Y\\Y\\[\\[\\[\\]\\]\\]\\]\\]\\]"
            ),
            .createMock(
                id: 20205,
                name: "Tunitas Creek Road",
                climbCategory: .category1,
                avgGrade: 6.2,
                elevationGain: 520.0,
                distance: 8400.0,
                distanceText: "8.40 km",
                elevationText: "520 m",
                gradeText: "6.2%",
                starred: false,
                startCoordinate: CLLocationCoordinate2D(latitude: 37.3512, longitude: -122.3234),
                endCoordinate: CLLocationCoordinate2D(latitude: 37.3845, longitude: -122.2845),
                polylineString: "u`{eFj_xjVGXGXIXIZIZKZK\\K\\M\\M\\M\\O\\O\\O\\Q\\Q\\S\\S\\S\\U\\U\\W\\W\\W\\Y\\Y\\[\\[\\[\\]\\]\\]\\]\\]\\]\\]\\]\\]\\]\\_\\a\\a\\a\\a\\c\\c\\c\\e\\e\\e\\g\\g\\g\\i\\i\\k\\k\\m\\m\\o\\o\\q\\q\\q\\s\\s"
            ),
            .createMock(
                id: 20206,
                name: "Portola Valley Loop",
                climbCategory: .category4,
                avgGrade: 4.2,
                elevationGain: 150.0,
                distance: 3600.0,
                distanceText: "3.60 km",
                elevationText: "150 m",
                gradeText: "4.2%",
                starred: true,
                startCoordinate: CLLocationCoordinate2D(latitude: 37.3845, longitude: -122.2089),
                endCoordinate: CLLocationCoordinate2D(latitude: 37.3998, longitude: -122.2345),
                polylineString: "wm|eF~crjVGXGXIXIZIZKZK\\M\\M\\M\\O\\O\\Q\\Q\\Q\\S\\S\\U\\U\\U\\W\\W\\Y\\Y\\[\\[\\[\\]\\]\\]"
            ),
            .createMock(
                id: 20207,
                name: "Sand Hill Road Climb",
                climbCategory: .none,
                avgGrade: 3.5,
                elevationGain: 85.0,
                distance: 2400.0,
                distanceText: "2.40 km",
                elevationText: "85 m",
                gradeText: "3.5%",
                starred: false,
                startCoordinate: CLLocationCoordinate2D(latitude: 37.4123, longitude: -122.1934),
                endCoordinate: CLLocationCoordinate2D(latitude: 37.4256, longitude: -122.2145),
                polylineString: "s_}eFlnsjVGXIXIZKZK\\M\\M\\O\\O\\Q\\Q\\S\\S\\U\\U\\W\\W\\Y\\[\\[\\]\\]"
            ),
            .createMock(
                id: 20208,
                name: "Arastradero Sprint",
                climbCategory: .none,
                avgGrade: 2.0,
                elevationGain: 25.0,
                distance: 1200.0,
                distanceText: "1.20 km",
                elevationText: "25 m",
                gradeText: "2.0%",
                starred: false,
                startCoordinate: CLLocationCoordinate2D(latitude: 37.3956, longitude: -122.1456),
                endCoordinate: CLLocationCoordinate2D(latitude: 37.4012, longitude: -122.1578),
                polylineString: "y||eFbepjVGXIZK\\M\\O\\Q\\S\\U\\W\\Y\\[\\]"
            )
        ]
    }
}
