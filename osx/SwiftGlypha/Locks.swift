//
//  Locks.swift
//  Glypha
//
//  Created by C.W. Betts on 5/28/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Foundation

final class Lock {
	private var mutex = pthread_mutex_t()
	
	init() {
		pthread_mutex_init(&mutex, nil)
	}
	
	deinit {
		pthread_mutex_destroy(&mutex)
	}
	
	func lock() {
		pthread_mutex_lock(&mutex)
	}
	
	func unlock() {
		pthread_mutex_unlock(&mutex)
	}
}

final class Locker {
	private let lock: Lock
	init(lock: Lock) {
		self.lock = lock
		self.lock.lock()
	}
	
	deinit {
		lock.unlock()
	}
}
