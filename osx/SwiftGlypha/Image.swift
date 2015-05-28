//
//  Image.swift
//  Glypha
//
//  Created by C.W. Betts on 5/27/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Foundation
import ImageIO
import OpenGL.GL

final class Image {
	private var texture: GLuint = 0
	private var alpha = false
	private(set) var width: Int32 = 0
	private(set) var height: Int32 = 0
	
	var loaded: Bool {
		return texture != 0
	}
	
	private func loadTextureData(texData: UnsafePointer<Void>, alpha hasAlpha: Bool = true) {
		loadTextureData(texData, format: hasAlpha ? GLenum(GL_BGRA_EXT) : GLenum(GL_BGR_EXT), hasAlpha: hasAlpha)
	}
	
	private func loadTextureData(texData: UnsafePointer<Void>, format: GLenum, hasAlpha: Bool) {
		alpha = hasAlpha
		
		// set pixel modes
		glPixelStorei(GLenum(GL_UNPACK_ROW_LENGTH), width);
		glPixelStorei(GLenum(GL_UNPACK_ALIGNMENT), 1);

		// generate new texture name and bind it
		glGenTextures(1, &texture);
		glBindTexture(GLenum(GL_TEXTURE_2D), texture);

		// GL_REPLACE prevents colors from seeping into a texture
		glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GLint(GL_REPLACE));
		// GL_NEAREST affects drawing the texture at different sizes
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_NEAREST));
		
		// set texture data
		glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA8, width, height, 0, format, GLenum(GL_UNSIGNED_BYTE), texData);
	}

	func load(data: NSData) {
		if let imageSource = CGImageSourceCreateWithData(data, nil), img = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
			width = Int32(CGImageGetWidth(img))
			height = Int32(CGImageGetHeight(img))
			if let colorSpace = CGColorSpaceCreateDeviceRGB() {
				let texData = calloc(Int(width * height) * 4, sizeof(Int8))
				if let ctx = CGBitmapContextCreate(texData, Int(width), Int(height), 8, Int(width) * 4, colorSpace, CGBitmapInfo(rawValue:CGImageAlphaInfo.PremultipliedFirst.rawValue) | .ByteOrder32Little) {
					CGContextDrawImage(ctx, CGRect(origin: .zeroPoint, size: CGSize(width: Int(width), height: Int(height))), img)
					loadTextureData(texData);

				}
				free(texData)
			}
		}
	}
	
	/*
	func draw(dest: UnsafeMutableBufferPointer<Point>, numDest: size_t, src: UnsafeMutableBufferPointer<Point>, numSrc: size_t) {

	}*/
	
	func draw(destination dest: [Point], source src: [Point]) {
		if (dest.count != src.count || dest.count < 3) {
			// bug
			return;
		}

		// set this texture as current
		glEnable(GLenum(GL_TEXTURE_2D))
		glBindTexture(GLenum(GL_TEXTURE_2D), texture)
		
		if alpha {
			// enable alpha blending
			glEnable(GLenum(GL_BLEND))
			glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
		}
		
		let quadOrPoly = GLenum(dest.count == 4 ? GL_QUADS : GL_POLYGON)
		// draw the texture
		glBegin(quadOrPoly);
		for i in 0..<dest.count {
			let destPt = dest[i];
			let srcPt = src[i];
			glTexCoord2f(Float(srcPt.h) / Float(width), Float(srcPt.v) / Float(height));
			glVertex2i(destPt.h, destPt.v);
		}
		glEnd();

		if alpha {
			glDisable(GLenum(GL_BLEND));
		}
		glDisable(GLenum(GL_TEXTURE_2D));
	}
	
	func draw(destination destRect: Rect, source srcRect: Rect) {
		var dest = Array<Point>(count: 4, repeatedValue: (0, 0))
		var src = dest
		
		dest[0] = Point(destRect.left, destRect.top);
		dest[1] = Point(destRect.left, destRect.bottom);
		dest[2] = Point(destRect.right, destRect.bottom);
		dest[3] = Point(destRect.right, destRect.top);
		src[0] = Point(srcRect.left, srcRect.top);
		src[1] = Point(srcRect.left, srcRect.bottom);
		src[2] = Point(srcRect.right, srcRect.bottom);
		src[3] = Point(srcRect.right, srcRect.top);
		draw(destination: dest, source: src)
	}
	
	func draw(destination destRect: Rect) {
		draw(destination: destRect, source: Rect(left: 0, top: 0, width: width, height: height))
	}
	
	func draw(#at: (x: Int32, y: Int32)) {
		draw(destination: Rect(left: at.x, top: at.y, width: width, height: height), source: Rect(left: 0, top: 0, width: width, height: height));
	}
}
