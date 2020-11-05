//
//  TabsListView.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/11/5.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import SwiftUI
import MyerSplashShared

struct TabSource: Identifiable, Hashable {
    var id: Int
    var content: String
    var displayTitle: String
    var deletable: Bool
}

class TabDataSource: ObservableObject {
    @Published var tabs: [TabSource] = []
    
    func removeTab(tab: TabSource) {
        tabs.removeAll { (t) -> Bool in
            t == tab
        }
    }
}

struct TabsRow: View {
    var title: TabSource
    var onClickDelete: (TabSource) -> Void
    
    var body: some View {
        HStack(alignment: VerticalAlignment.center, spacing: 12, content: {
            Text(title.displayTitle)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Font.system(size: FontSizes.contentFontSize))
            
            if title.deletable {
                Button(action:{
                    onClickDelete(title)
                }) {
                    HStack {
                        Image(R.icons.ic_delete)
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                .frame(width: 40, height: 40)
                .foregroundColor(Color.red)
                .cornerRadius(20)
            }
        })
    }
}

struct TabsListView: View {
    @EnvironmentObject var tabDataSource: TabDataSource
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 0) {
            List {
                ForEach(tabDataSource.tabs, id: \.self) { tab in
                    TabsRow(title: tab) { (t) in
                        tabDataSource.removeTab(tab: t)
                    }
                }
                .moveDisabled(true)
            }
        }.padding(.top, getContentTopInsets())
    }
}
