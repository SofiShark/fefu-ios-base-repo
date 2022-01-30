import UIKit
import Charts

struct ActivityGraph {
    let activities: [ActivitiesTableModel]
    let duration: Double
    let distance: Double
    
    func formattedDuration() -> String {
        return duration.duration()
    }
    func formattedDistance() -> String {
        return String(format: "%.2f", distance / 1000) + " км"
    }
}

class ProfileController: UITableViewController {

    private var graphData: ActivityGraph?
    private var user: UserModel? {
        didSet {
            nameLabel?.text = user?.name
            loginLabel?.text = user?.login
            genderLabel?.text = user?.gender.name
        }
    }

    @IBOutlet var activityChartsView: LineChartView!
    @IBOutlet var profileTable: UITableView! {
        didSet {
            profileTable.delegate = self
        }
    }
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        API.profile { user in
            DispatchQueue.main.async {
                self.user = user
            }
        } reject: { err in
            print(err)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadGraph()
    }

    @IBAction func logoutHandler(_ sender: Any) {
        API.logout {
            DispatchQueue.main.async {
                UserDefaults.standard.removeObject(forKey: "token")
                let vc = UIStoryboard(name: "Greeting", bundle: nil).instantiateInitialViewController()
                vc?.modalPresentationStyle = .fullScreen
                self.present(vc!, animated: true, completion: nil)
            }
        } reject: { error in
            print(error)
        }
    }
    
    func loadGraph() {
        loadActivityCharts()
        distanceLabel.text = graphData?.formattedDistance()
        durationLabel.text = graphData?.formattedDuration()
    }
    
    private func loadActivityCharts() {
        fetchUserActivities()
        
        let dateDay = DateFormatter()
        dateDay.dateFormat = "dd"
        guard let currentDay = Int(dateDay.string(from: Date())) else {
            return
        }

        var entries: [ChartDataEntry] = Array(0...6).map {
            ChartDataEntry(x: Double(currentDay - 6 + $0), y: 0)
        }

        graphData?.activities.enumerated().forEach { ind, activities in
            if let entryDay = Int(dateDay.string(from: activities.date)) {
                let entryPos = 6 - (currentDay - entryDay)
                entries[entryPos] = ChartDataEntry(x: Double(entryDay),
                                                   y: activities.activities.reduce(0, { sum, activity in
                                                       sum + activity.distance / 1000
                                                   }))
            }
        }

        let lineChartDataSet = LineChartDataSet(entries: entries, label: nil)
        let lineChartData = LineChartData(dataSet: lineChartDataSet)

        activityChartsView.data = lineChartData

        activityChartsView.dragEnabled = false
        activityChartsView.doubleTapToZoomEnabled = false
        activityChartsView.setVisibleYRange(minYRange: 0, maxYRange: activityChartsView.chartYMax * 1.5, axis: .left)

        activityChartsView.rightAxis.drawLabelsEnabled = false

        activityChartsView.xAxis.labelPosition = .bottom
    }

    private func fetchUserActivities() {
        let context = FEFUCoreDataContainer.instance.context
        let request = CDActivity.fetchRequest()
        
        var duration: Double = 0
        var distance: Double = 0

        do {
            let rawActivities = try context.fetch(request)
            let activities: [ActivityTableCellModel] = rawActivities.map { activity in
                let image = UIImage(systemName: "bicycle.circle.fill") ?? UIImage()
                return ActivityTableCellModel(distance: activity.distance,
                                              duration: activity.duration,
                                              type: activity.type,
                                              icon: image,
                                              startDate: activity.startDate,
                                              endDate: activity.endDate,
                                              name: "")
            }
            
            let weekAgoDate = Date().shift(unit: .day, value: -7)!
            let filtredActivities = activities.filter { $0.startDate >  weekAgoDate }
            filtredActivities.map { activity in
                distance += activity.distance
                duration += activity.duration
            }
            let sortedActivities = filtredActivities.sorted { $0.startDate > $1.startDate }
            let grouppedActivities = Dictionary(grouping: sortedActivities, by: { $0.startDate.callendarDate() }).sorted(by: {
                $0.key > $1.key
            })
            graphData = ActivityGraph(activities: grouppedActivities.map { (date, activities) in
                return ActivitiesTableModel(date: date, activities: activities)
            }, duration: duration, distance: distance)
        } catch {
            print(error)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if (cell.restorationIdentifier == "ChangePassword") {
                performSegue(withIdentifier: "ChangePassword", sender: self)
            }
        }
    }
}
