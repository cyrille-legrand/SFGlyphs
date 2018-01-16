import UIKit

extension String {
    var hexScalars: String { get {
        return self.unicodeScalars.map({ String(format: "%X", $0.value) }).joined(separator: " ")
    }}
}

class ViewController: UITableViewController {
    let combiners: [String] = ["⃞", "⃝", "⃞■", "⃝●"]
    let letters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+−×÷=<>#◀▲▼▶?!✓✗"
    
    var size: CGFloat = 24 { didSet {
        tableView.reloadData()
        slider.value = Float(size)
    }}
    
    @IBOutlet weak var seg: UISegmentedControl!
    
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seg.removeAllSegments()
        seg.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 24)
        ], for: .normal)
        
        combiners.forEach { combiner in
            seg.insertSegment(withTitle: "A"+combiner, at: seg.numberOfSegments, animated: false)
        }
        seg.selectedSegmentIndex = 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return letters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        
        cell.setup(
            base: String(letters[letters.index(letters.startIndex, offsetBy: indexPath.row)]),
            combiner: combiners[seg.selectedSegmentIndex],
            size: size
        )
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? Cell else { return }
        UIPasteboard.general.string = cell.result.text
    }

    @IBAction func segDidChange(_ sender: Any) {
        tableView.reloadData()
    }
    
    @IBAction func sliderDidChange(_ sender: UISlider) {
        size = CGFloat(sender.value)
    }
    
    func allStrings() -> String {
        return letters.map({ char -> String in
            let letter = String(char)
            return combiners.map({ combiner -> String in
                return "\(letter+combiner) = \(letter) +  \(combiner) (\(letter.hexScalars) \(combiner.hexScalars))"
            }).joined(separator: "\n")
            
        }).joined(separator: "\n")
    }
    
    @IBAction func didTapSend(_ sender: UIBarButtonItem) {
        let activityVC = UIActivityViewController(activityItems: [allStrings()], applicationActivities: nil)
        
        if let pop = activityVC.popoverPresentationController {
            pop.barButtonItem = sender
            pop.permittedArrowDirections = .up
        }
        present(activityVC, animated: true, completion: nil)
    }
}

class Cell: UITableViewCell {
    @IBOutlet weak var base: UILabel!
    @IBOutlet weak var baseCode: UILabel!
    @IBOutlet weak var combiner: UILabel!
    @IBOutlet weak var combinerCode: UILabel!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var resultCode: UILabel!
    
    func setup(base: String, combiner: String, size: CGFloat) {
        self.base.text = base
        self.combiner.text = combiner
        self.result.text = base + combiner
        
        self.baseCode.text = base.hexScalars
        self.combinerCode.text = combiner.hexScalars
        
        self.base.font = UIFont.systemFont(ofSize: size)
        self.combiner.font = self.base.font
        self.result.font = UIFont.systemFont(ofSize: size * 1.5)
    }
}
