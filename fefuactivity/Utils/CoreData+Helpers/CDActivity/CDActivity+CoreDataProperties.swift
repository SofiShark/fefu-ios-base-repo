import Foundation
import CoreData
import CoreLocation

extension CDActivity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDActivity> {
        return NSFetchRequest<CDActivity>(entityName: "CDActivity")
    }

    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var type: String
    @NSManaged public var distance: Double
    @NSManaged public var duration: Double
}

extension CDActivity : Identifiable {

}
