//
//  Utilities.swift
//  Glypha
//
//  Created by C.W. Betts on 5/28/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Foundation

final class Utilities {
	private var machConvert: Double
	
	init() {
		var timebaseInfo = mach_timebase_info_data_t()
		mach_timebase_info(&timebaseInfo);
		machConvert = (Double(timebaseInfo.numer) / Double(timebaseInfo.denom)) / Double(NSEC_PER_SEC)
	}
	
	var now: Double {
		return Double(mach_absolute_time()) * machConvert
	}
	
	func randomInt32(end: Int32) -> Int32 {
		return Int32(random() % Int(end))
	}
}
