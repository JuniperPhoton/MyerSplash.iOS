//
//  FilterButton.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/10/25.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents.MaterialButtons
import MyerSplashShared
import PinLayout

 let transitionController = MDCDialogTransitionController()

 let filters = [R.strings.filter_all, R.strings.filter_portrait, R.strings.filter_landscape]

 let filterOptions = [0 : FilterOption.All,
                             1 : FilterOption.Portrait,
                             2 : FilterOption.Landscape]

 let filterOptionsToIndex = [FilterOption.All : 0,
                                    FilterOption.Portrait : 1,
                                    FilterOption.Landscape: 2]

extension UIViewController {
    func showFilterDialog(viewControllerToRefresh: ImagesViewController) {
        guard let selectedIndex = filterOptionsToIndex[viewControllerToRefresh.imageRepo!.filterOption] else {
            return
        }
        
        let filterChoiceContent = SingleChoiceDialog(title: R.strings.filter_title, options: filters, selected: selectedIndex)
        
        presentBottomSheet(content: filterChoiceContent, transitionController: transitionController) { [weak viewControllerToRefresh] (selectedIndex) in
            guard let vc = viewControllerToRefresh else {
                return
            }
            
            guard let filterOption = filterOptions[selectedIndex] else {
                return
            }
            
            vc.imageRepo?.filterOption = filterOption
            vc.refreshData()
        }
    }
}

class FilterButton: MDCFloatingButton {
    override init(frame: CGRect = CGRect.zero, shape: MDCFloatingButtonShape = .default) {
        super.init(frame: frame, shape: shape)
        
        let image = UIImage(named: R.icons.ic_filter_list)?.withRenderingMode(.alwaysTemplate)
        setImage(image, for: .normal)
        tintColor = UIColor.black
        backgroundColor = UIColor.white
        alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutAsFab() {
        pin.right(16).bottom(UIView.hasTopNotch ? 24.cgFloat : 16.cgFloat).size(MainViewController.BAR_BUTTON_SIZE)
    }
}
