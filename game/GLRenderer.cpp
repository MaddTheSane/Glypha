#include "GLRenderer.h"

void GL::Renderer::resize(int width, int height)
{
    GLsizei w = width, h = height;
	
	glViewport(0, 0, w, h);
    
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0.0, w, h, 0.0, 0.0, 1.0);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
    
    bounds_.setSize(width, height);
}

void GL::Renderer::clear()
{
    if (didPrepare_ == false) {
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        didPrepare_ = true;
    }
    
	glClear(GL_COLOR_BUFFER_BIT);
	glLoadIdentity();
}

void GL::Renderer::fillRect(const GL::Rect& rect)
{
	glBegin(GL_QUADS);
	glVertex2i(rect.left, rect.bottom);
	glVertex2i(rect.left, rect.top);
	glVertex2i(rect.right, rect.top);
	glVertex2i(rect.right, rect.bottom);
	glEnd();
}

void GL::Renderer::setFillColor(int red, int green, int blue)
{
    glColor3f((GLfloat)red, (GLfloat)green, (GLfloat)blue);
}

GL::Rect GL::Renderer::bounds()
{
    return bounds_;
}

void GL::Renderer::beginLines(float lineWidth)
{
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_LINE_SMOOTH);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
	glLineWidth(lineWidth);
	glBegin(GL_LINES);
}

void GL::Renderer::endLines()
{
	glEnd();
	glDisable(GL_LINE_SMOOTH);
	glDisable(GL_BLEND);
}

void GL::Renderer::moveTo(int h, int v)
{
    lineStart_.h = h;
    lineStart_.v = v;
}

void GL::Renderer::lineTo(int h, int v)
{
	glVertex2s(lineStart_.h, lineStart_.v);
	glVertex2s(h, v);
}
