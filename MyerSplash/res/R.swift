//
//  R.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/1/11.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit

public class R {
    public class colors {
        public static let rippleColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.2)
    }
    
    public class icons {
        public static let ic_clear = "ic_clear"
        public static let ic_delete = "ic_delete"
        public static let ic_done = "ic_done"
        public static let ic_exposure = "ic_exposure"
        public static let ic_download = "ic_download"
        public static let ic_launcher = "ic_launcher"
        public static let ic_more = "ic_more"
        public static let ic_search = "ic_search"
        public static let ic_filter_list = "ic_filter_list"
        public static let ic_settings = "ic_settings"
        public static let ic_star = "ic_star"
        public static let ic_app_icon = "ic_app_icon"
        public static let ic_home = "ic_home"
        public static let ic_retry = "ic_retry"
        public static let ic_share = "ic_share"
        public static let ic_save = "ic_save"

        private init() {
            
        }
    }
    
    public class strings {
        public static let tab_new = NSLocalizedString("tab_new", comment: "")
        public static let tab_highlights = NSLocalizedString("tab_highlights", comment: "")
        public static let tab_random = NSLocalizedString("tab_random", comment: "")
        public static let tab_developer = NSLocalizedString("tab_developer", comment: "")
        
        public static let tab_downloads = NSLocalizedString("tab_downloads", comment: "")
        public static let tab_settings = NSLocalizedString("tab_settings", comment: "")
        public static let tab_about = NSLocalizedString("tab_about", comment: "")
        
        public static let author = NSLocalizedString("author", comment: "")
        public static let recommend_by = NSLocalizedString("recommend_by", comment: "")
        public static let download = NSLocalizedString("download", comment: "")
        public static let today = NSLocalizedString("today", comment: "")
        public static let edit = NSLocalizedString("edit", comment: "")
        public static let no_items = NSLocalizedString("no_items", comment: "")
        public static let uh_oh = NSLocalizedString("uh_oh", comment: "")
        public static let retry = NSLocalizedString("retry", comment: "")
        public static let something_wrong = NSLocalizedString("something_wrong", comment: "")
        public static let no_more_items = NSLocalizedString("no_more_items", comment: "")

        public static let saved_album = NSLocalizedString("saved_album", comment: "")
        public static let failed_process = NSLocalizedString("failed_process", comment: "")
        public static let failed_save = NSLocalizedString("failed_save", comment: "")
        
        public static let search_hint = NSLocalizedString("search_hint", comment: "")
        public static let search_title = NSLocalizedString("search_title", comment: "")

        public static let cancel = NSLocalizedString("cancel", comment: "")
        public static let delete_dialog_title = NSLocalizedString("delete_dialog_title", comment: "")
        public static let delete_dialog_message = NSLocalizedString("delete_dialog_message", comment: "")
        public static let delete_dialog_action_delete = NSLocalizedString("delete_dialog_action_delete", comment: "")

        public static let about_credit = NSLocalizedString("about_credit", comment: "")
        public static let about_credit_content = NSLocalizedString("about_credit_content", comment: "")
        public static let about_feedback = NSLocalizedString("about_feedback", comment: "")
        public static let about_feedback_email = NSLocalizedString("about_feedback_email", comment: "")
        public static let about_feedback_email_body = NSLocalizedString("about_feedback_email_body", comment: "")

        public static let settings_personalization = NSLocalizedString("settings_personalization", comment: "")
        public static let settings_metered = NSLocalizedString("settings_metered", comment: "")
        public static let settings_metered_message = NSLocalizedString("settings_metered_message", comment: "")
        public static let settings_quality = NSLocalizedString("settings_quality", comment: "")
        public static let settings_quality_browsing = NSLocalizedString("settings_quality_browsing", comment: "")
        public static let settings_quality_browsing_large = NSLocalizedString("settings_quality_browsing_large", comment: "")
        public static let settings_quality_browsing_small = NSLocalizedString("settings_quality_browsing_small", comment: "")
        public static let settings_quality_browsing_thumb = NSLocalizedString("settings_quality_browsing_thumb", comment: "")
        public static let settings_quality_download = NSLocalizedString("settings_quality_download", comment: "")
        public static let settings_quality_download_large = NSLocalizedString("settings_quality_download_large", comment: "")
        public static let settings_quality_download_small = NSLocalizedString("settings_quality_download_small", comment: "")
        public static let settings_quality_download_thumb = NSLocalizedString("settings_quality_download_thumb", comment: "")
        public static let settings_clear = NSLocalizedString("settings_clear", comment: "")
        public static let settings_clear_cache = NSLocalizedString("settings_clear_cache", comment: "")
        
        public static let settings_dark_mask_title = NSLocalizedString("settings_dark_mask_title", comment: "")
        public static let settings_dark_mask_content = NSLocalizedString("settings_dark_mask_content", comment: "")
        
        public static let settings_no_sponsorship_title = NSLocalizedString("settings_no_sponsorship_title", comment: "")
        public static let settings_no_sponsorship_content = NSLocalizedString("settings_no_sponsorship_content", comment: "")
        
        public static let cleared = NSLocalizedString("cleared", comment: "")
        public static let download_in_background = NSLocalizedString("download_in_background", comment: "")
        public static let no_network = NSLocalizedString("no_network", comment: "")

        public static let metered_dialog_title = NSLocalizedString("metered_dialog_title", comment: "")
        public static let metered_dialog_message = NSLocalizedString("metered_dialog_message", comment: "")
        
        public static let download_cancelled = NSLocalizedString("download_cancelled", comment: "")
        public static let shortcut_search = NSLocalizedString("shortcut_search", comment: "")
        public static let shortcut_downloads = NSLocalizedString("shortcut_downloads", comment: "")

        public static let failed_to_load = NSLocalizedString("failed_to_load", comment: "")
        public static let saved_mac = NSLocalizedString("saved_mac", comment: "")
        public static let open_in_folder = NSLocalizedString("open_in_folder", comment: "")
        public static let share_content = NSLocalizedString("share_content", comment: "")
        public static let share_content_highlight = NSLocalizedString("share_content_highlight", comment: "")
        public static let about_website = NSLocalizedString("about_website", comment: "")

        public static let widget_title = NSLocalizedString("widget_title", comment: "")
        public static let widget_desc = NSLocalizedString("widget_desc", comment: "")
        
        public static let filter_title = NSLocalizedString("filter_title", comment: "")
        public static let filter_all = NSLocalizedString("filter_all", comment: "")
        public static let filter_landscape = NSLocalizedString("filter_landscape", comment: "")
        public static let filter_portrait = NSLocalizedString("filter_portrait", comment: "")

        public static let month_01 = NSLocalizedString("month_01", comment: "")
        public static let month_02 = NSLocalizedString("month_02", comment: "")
        public static let month_03 = NSLocalizedString("month_03", comment: "")
        public static let month_04 = NSLocalizedString("month_04", comment: "")
        public static let month_05 = NSLocalizedString("month_05", comment: "")
        public static let month_06 = NSLocalizedString("month_06", comment: "")
        public static let month_07 = NSLocalizedString("month_07", comment: "")
        public static let month_08 = NSLocalizedString("month_08", comment: "")
        public static let month_09 = NSLocalizedString("month_09", comment: "")
        public static let month_10 = NSLocalizedString("month_10", comment: "")
        public static let month_11 = NSLocalizedString("month_11", comment: "")
        public static let month_12 = NSLocalizedString("month_12", comment: "")

        private init() {
            
        }
    }
    
    private init() {
        
    }
}
