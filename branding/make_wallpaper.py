"""Generate the Noctora 'Afterdark' wallpaper: midnight sky, stars, warm glow on the horizon."""
import random, sys
from PIL import Image, ImageDraw, ImageFilter

def make(w, h, path, seed=7):
    random.seed(seed)
    top, bottom = (5, 8, 22), (20, 28, 66)
    img = Image.new("RGB", (w, h))
    px = img.load()
    for y in range(h):
        t = y / (h - 1)
        c = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        for x in range(w):
            px[x, y] = c
    # warm "lights going down" glow along the bottom
    glow = Image.new("RGB", (w, h), (0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([-w * 0.2, h * 0.78, w * 1.2, h * 1.45], fill=(255, 150, 50))
    glow = glow.filter(ImageFilter.GaussianBlur(h * 0.09))
    img = Image.blend(img, Image.composite(glow, img, glow.convert("L")), 0.35)
    # stars, denser and brighter toward the top
    d = ImageDraw.Draw(img)
    for _ in range(int(w * h / 9000)):
        x, y = random.random() * w, (random.random() ** 1.8) * h * 0.8
        r = random.choice([0.6, 0.8, 1.0, 1.0, 1.4, 2.0]) * w / 1920
        b = random.randint(150, 255)
        d.ellipse([x - r, y - r, x + r, y + r], fill=(b, b, min(255, b + 20)))
    img.save(path, optimize=True)

out = sys.argv[1]
for w, h in [(3840, 2160), (1920, 1080)]:
    make(w, h, f"{out}/{w}x{h}.png")
print("done")
