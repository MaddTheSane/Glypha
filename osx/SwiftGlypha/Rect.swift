//
//  Rect.swift
//  Glypha
//
//  Created by C.W. Betts on 5/27/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Foundation

struct Rect {
	var top: Int32
	var left: Int32
	var bottom: Int32
	var right: Int32
	
	init() {
		top = 0
		left = 0
		bottom = 0
		right = 0
	}
	
	init(width: Int32, height: Int32) {
		self.init()
		bottom = width
		right = height
	}
	
	init(left: Int32, top: Int32, width: Int32, height: Int32) {
		self.left = left
		self.top = top
		bottom = top + height
		right = left + width
	}
	
	init(left theLeft: Int32, top theTop: Int32, right theRight: Int32, bottom theBottom: Int32) {
		left = theLeft;
		top = theTop;
		right = theRight;
		bottom = theBottom;
	}

	var width: Int32 {
		get {
			return right - left;
		}
		set {
			right = left + newValue;
		}
	}
	
	var height: Int32 {
		return bottom - top;
	}
	
	var size: (width: Int32, height: Int32) {
		get {
			return (left - right, top - bottom)
		}
		set {
			right = left + newValue.width;
			bottom = top + newValue.height;
		}
	}
	
	mutating func offsetBy(#horizontal: Int32, vertical: Int32) {
		left += horizontal;
		right += horizontal;
		top += vertical;
		bottom += vertical;
	}
	
	/// Offset rect to (0, 0)
	mutating func zeroCorner() {
		right -= left;
		bottom -= top;
		left = 0;
		top = 0;
	}
	
	func sect(r2: Rect) -> Bool {
		return (left < r2.right && right > r2.left && top < r2.bottom && bottom > r2.top);
	}

	mutating func inset(#dh: Int32, dv: Int32) {
		left += dh;
		right -= (dh * 2);
		top += dv;
		bottom -= (dv * 2);
	}
}
