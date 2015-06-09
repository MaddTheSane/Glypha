//
//  Render.swift
//  Glypha
//
//  Created by C.W. Betts on 5/27/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Cocoa
import OpenGL.GL

final class Renderer {
	private(set) var bounds: Rect
	private var didPrepare = false
	private var lineStart: Point = (0,0)
	
	init() {
		bounds = Rect()
	}
	
	func resize(width width: Int32, height: Int32) {
		let w = GLsizei(width)
		let h = GLsizei(height)
		glViewport(0, 0, w, h)
		
		glMatrixMode(GLenum(GL_PROJECTION))
		glLoadIdentity();
		glOrtho(0.0, GLdouble(w), GLdouble(h), 0.0, 0.0, 1.0);
		
		glMatrixMode(GLenum(GL_MODELVIEW));
		glLoadIdentity();

		bounds.size = (width, height)
	}

	func clear() {
		if didPrepare == false {
			glClearColor(0.0, 0.0, 0.0, 0.0);
			didPrepare = true;
		}
		
		glClear(GLenum(GL_COLOR_BUFFER_BIT));
		glLoadIdentity();
	}
	
	func fillRect(rect: Rect) {
		glBegin(GLenum(GL_QUADS))
		glVertex2i(rect.left, rect.bottom);
		glVertex2i(rect.left, rect.top);
		glVertex2i(rect.right, rect.top);
		glVertex2i(rect.right, rect.bottom);
		glEnd();
	}
	
	func setFillColor(red red: Int32, green: Int32, blue: Int32) {
		glColor3f(GLfloat(red), GLfloat(green), GLfloat(blue))
	}

	func beginLines(lineWidth: Float = 1) {
		glEnable(GLenum(GL_BLEND))
		glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
		glEnable(GLenum(GL_LINE_SMOOTH))
		glHint(GLenum(GL_LINE_SMOOTH_HINT), GLenum(GL_NICEST))
		glLineWidth(lineWidth)
		glBegin(GLenum(GL_LINES))
	}
	
	func endLines() {
		glEnd();
		glDisable(GLenum(GL_LINE_SMOOTH));
		glDisable(GLenum(GL_BLEND));
	}

	func moveTo(h h: Int32, v: Int32) {
		moveTo(point: (v,h))
	}
	
	func moveTo(point point: Point) {
		lineStart = point
	}
	
	func lineTo(h h: Int32, v: Int32) {
		lineTo(point: (v,h))
	}
	
	func lineTo(point point: Point) {
		glVertex2i(lineStart.h, lineStart.v)
		glVertex2i(point.h, point.v)
	}
}
