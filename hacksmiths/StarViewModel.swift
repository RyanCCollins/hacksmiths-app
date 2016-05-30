//
//  StarViewModel.swift
//  hacksmiths
//
//  Created by Ryan Collins on 5/30/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit

/* MVVM protocol for setting Image as Starred*/
protocol StarTogglePresentable {
    var starred: Bool { get }
    var image: UIImage { get }
    var color: UIColor { get }
    func toggleStarState(on: Bool)
}

//struct StarViewModel: StarTogglePresentable {
//    let starredImage = UIImage(named: "star-white-full")
//    let unstarredImage = UIImage(named: "star-white")
//    let starredColor = UIColor.whiteColor()
//    let unstarredColor = UIColor(hex: "#d4af37")
//    var starred: Bool = false
//    let starModel: Star?
//    
//    var color: UIColor = {
//
//    }
//    
//    var image: UIImage = {
//        
//    }
//    
//    func toggleStarState() {
//
//    }
//}