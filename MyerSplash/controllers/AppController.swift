import Foundation
import UIKit

class AppController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let main = MainViewController(nibName: nil, bundle: nil)
        show(main, sender: self)
        //pushViewController(main, animated: false)
        //setNavigationBarHidden(true, animated: false)
    }
}
