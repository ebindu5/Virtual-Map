//
//  GCD.swift
//  Virtual Tourist
//
//  Created by NISHANTH NAGELLA on 5/17/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
