import UIKit

struct ActivityTableCellModel {
    let distance: Double
    let duration: Double
    let type: String
    let icon: UIImage
    let startDate: Date
    let endDate: Date
    let name: String

    func timeAgo() -> String {
        return startDate.timeAgo(Date())
    }
    func startTime() -> String {
        return startDate.clockDisplay()
    }
    func endTime() -> String {
        return endDate.clockDisplay()
    }
    func formattedDistance() -> String {
        return String(format: "%.2f", distance / 1000) + " км"
    }
    func formattedDuration() -> String {
        return duration.duration()
    }
}

class ActivityTableCellController: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var typeIcon: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        cellView.layer.cornerRadius = 10
    }

    func bind(_ model: ActivityTableCellModel) {
        distanceLabel.text = model.formattedDistance()
        nameLabel.text = model.name.count != 0 ? "@\(model.name)" : ""
        durationLabel.text = model.formattedDuration()
        typeIcon.image = model.icon
        typeLabel.text = model.type
        timeAgoLabel.text = model.timeAgo()
    }
}
