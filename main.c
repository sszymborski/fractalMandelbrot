#include <stdio.h>
#include <stdlib.h>

#include "mandel.h"

#include <stdio.h>
#include <stdlib.h>
#include <GL/glut.h>
#include <GL/gl.h>
#include <GL/glu.h>


void set_texture();

typedef struct
{
    unsigned char r, g, b;
} rgb_t;
int help=0;
rgb_t **tex = 0;
int gwin;
GLuint texture;
int width, height;
int tex_w, tex_h;
double scale = 1./256;
double cx = -.6, cy = 0;
int max_iter = 256;

void render()
{
    double	x = (double)width /tex_w,
            y = (double)height/tex_h;
    glClear(GL_COLOR_BUFFER_BIT);
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    glBindTexture(GL_TEXTURE_2D, texture);
    glBegin(GL_QUADS);
    glTexCoord2f(0, 0);
    glVertex2i(0, 0);
    glTexCoord2f(x, 0);
    glVertex2i(width, 0);
    glTexCoord2f(x, y);
    glVertex2i(width, height);
    glTexCoord2f(0, y);
    glVertex2i(0, height);
    glEnd();
    glFlush();
    glFinish();
}


void keypress(unsigned char key, int x, int y)
{
    switch(key)
    {
    case 'q':
        glFinish();
        glutDestroyWindow(gwin);
        return;
    case 27:
        scale = 1./256;
        cx = -.6;
        cy = 0;
        break;
    case '>':
    case '.':
        max_iter += 128;
        if (max_iter > 1 << 15) max_iter = 1 << 15;
        printf("max iter: %d\n", max_iter);
        break;

    case '<':
    case ',':
        max_iter -= 128;
        if (max_iter < 128) max_iter = 128;
        printf("max iter: %d\n", max_iter);
        break;

    case 'z':
        max_iter = 4096;
        break;
    case 'x':
        max_iter = 128;
        break;
    }
    set_texture();
}


void calc_mandel(double scale, double cx, double cy, int height, int width, int max_iter)
{
    printf("%lf, %lf, %lf, %d\n", scale, cx, cy, max_iter);
    unsigned char px[3*640*480];
    int ii;
    for(ii=0; ii<3*640*480; ++ii)
        px[ii]=255;
    help+=5;
    for(ii=3*640*80; ii<3*640*160; ++ii)
        px[ii]=44;
    mandel(px, scale, cx, cy, max_iter);
    int k=0;
    int i,j;
    rgb_t *ppx;
    for (i = 0; i < height; i++)
        for (j = 0, ppx = tex[i]; j  < width; j++, ppx++)
        {
            ppx->r = px[k];
            ++k;
            ppx->g = px[k];
            ++k;
            ppx->b = px[k];
            ++k;
        }
}

void alloc_tex()
{
    int i, ow = tex_w, oh = tex_h;
    for (tex_w = 1; tex_w < width;  tex_w <<= 1);
    for (tex_h = 1; tex_h < height; tex_h <<= 1);
    if (tex_h != oh || tex_w != ow)
        tex = realloc(tex, tex_h * tex_w * 3 + tex_h * sizeof(rgb_t*));
    for (tex[0] = (rgb_t *)(tex + tex_h), i = 1; i < tex_h; i++)
        tex[i] = tex[i - 1] + tex_w;
}

void set_texture()
{
    alloc_tex();
    calc_mandel(scale, cx, cy, height, width, max_iter);
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, 3, tex_w, tex_h,
                 0, GL_RGB, GL_UNSIGNED_BYTE, tex[0]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    render();
}

void mouseclick(int button, int state, int x, int y)
{
    if (state != GLUT_UP) return;
    cx += (x - width / 2) * scale;
    cy -= (y - height/ 2) * scale;
    switch(button)
    {
    case GLUT_LEFT_BUTTON:
        if (scale > fabs(x) * 1e-16 && scale > fabs(y) * 1e-16)
            scale /= 2;
        break;
    case GLUT_RIGHT_BUTTON:
        scale *= 2;
        break;
    }
    set_texture();
}


void resize(int w, int h)
{
    printf("resize %d %d\n", w, h);
    width = w;
    height = h;
    glViewport(0, 0, w, h);
    glOrtho(0, w, 0, h, -1, 1);
    set_texture();
}

void init_gfx(int *c, char **v)
{
    glutInit(c, v);
    glutInitWindowSize(640, 480);
    glutInitDisplayMode(GLUT_RGB);
    gwin = glutCreateWindow("Mandelbrot");
    glutDisplayFunc(render);
    glutKeyboardFunc(keypress);
    glutMouseFunc(mouseclick);
    glutReshapeFunc(resize);
    glGenTextures(1, &texture);
    set_texture();
}

int main(int c, char **v)
{
    init_gfx(&c, v);
    printf("keys:\n\tc: monochrome[nope]\n\ts: screen dump[nope]\n\t"
           "<, >: decrease/increase max iteration\n\tq: quit\n\tmouse buttons to zoom\n");
    glutMainLoop();
    return 0;
}

