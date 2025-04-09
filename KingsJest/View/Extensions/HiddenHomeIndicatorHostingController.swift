//
//  File.swift
//  KingsJest
//
//  Created by Luiz Seibel on 07/04/25.
//

import Foundation
import SwiftUI

class HomeIndicatorHostingController<Content: View>: UIHostingController<Content> {
    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
    
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        nil
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        .bottom
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
    }
}
