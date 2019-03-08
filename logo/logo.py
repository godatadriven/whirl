import turtle
import canvasvg
import sys
import cairosvg

sys.setrecursionlimit(10000)

COLORS = [
    (225, 0, 0),
    (0, 225, 225),
    (102, 225, 51),
    (51, 153, 225)
]


def create_whirl(size, sides, angle_diff, shorten_with, min_line_length):
    angle = 360 / sides

    def create_inner(length, step):
        t.pencolor(COLORS[step % len(COLORS)])
        t.right(angle + angle_diff)
        t.forward(length)
        new_length = length - shorten_with
        if new_length > min_line_length:
            create_inner(new_length, step + 1)

    # t.left(angle/2)
    for x in range(0, sides):
        t.pencolor(COLORS[x % len(COLORS)])
        t.forward(size)
        if x < sides - 1:
            t.right(angle)

    create_inner(size - shorten_with, 0)


def create_whirl_logo():
    create_whirl(size=50, sides=12, angle_diff=0.1, shorten_with=0.12, min_line_length=2)


t = turtle.Turtle()
turtle.colormode(255)
t.hideturtle()
t.color(0, 0, 0)
t.speed(0)
t.pensize(2)

create_whirl_logo()

t.hideturtle()
t.color(255, 255, 255)
ts = turtle.getscreen().getcanvas()
canvasvg.saveall("logo.svg", ts)

with open("logo.svg") as svg_input, open("logo.png", 'wb') as png_output:
    cairosvg.svg2png(bytestring=svg_input.read(), write_to=png_output)
