"""
Generate launch-kit PNGs for claude-auth-setup.

Outputs to ./ (content/images/). Run with: python generate.py
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# ----- Palette -----
BG          = (13, 17, 23)        # GitHub dark
CARD        = (22, 27, 34)
CARD_HI     = (33, 38, 45)
BORDER      = (48, 54, 61)
TEXT        = (230, 237, 243)
MUTED       = (125, 133, 144)
ACCENT      = (255, 107, 53)      # warm orange (brand)
ACCENT_DIM  = (180, 75, 37)
SUCCESS     = (63, 185, 80)
WARN        = (248, 81, 73)
HIGHLIGHT   = (255, 166, 87)

# ----- Fonts -----
F_BLACK = "C:/Windows/Fonts/seguibl.ttf"
F_BOLD  = "C:/Windows/Fonts/segoeuib.ttf"
F_REG   = "C:/Windows/Fonts/segoeui.ttf"
F_MONO  = "C:/Windows/Fonts/CascadiaMono.ttf"
F_MONO_B= "C:/Windows/Fonts/consolab.ttf"

def font(path, size):
    return ImageFont.truetype(path, size)

# ----- Helpers -----
def gradient_bg(w, h, c1=BG, c2=(8, 11, 18)):
    img = Image.new("RGB", (w, h), c1)
    base = Image.new("RGB", (w, h), c2)
    mask = Image.new("L", (w, h))
    md = mask.load()
    for y in range(h):
        v = int(255 * (y / h) ** 1.5)
        for x in range(w):
            md[x, y] = v
    return Image.composite(base, img, mask)

def radial_glow(w, h, cx, cy, radius, color, alpha=80):
    glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(glow)
    for i in range(40, 0, -1):
        r = int(radius * (i / 40))
        a = int(alpha * (1 - i / 40))
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=color + (a,))
    return glow

def rounded_box(draw, xy, radius, fill=None, outline=None, width=1):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)

def text_w(draw, txt, fnt):
    bb = draw.textbbox((0, 0), txt, font=fnt)
    return bb[2] - bb[0]

def draw_brand_strip(img, draw, x, y, w=None):
    """Small brand mark: orange dot + monospace project name."""
    f = font(F_MONO_B, 18)
    dot_r = 5
    draw.ellipse((x, y + 6, x + dot_r * 2, y + 6 + dot_r * 2), fill=ACCENT)
    draw.text((x + dot_r * 2 + 10, y), "claude-auth-setup", font=f, fill=MUTED)

def add_subtle_grid(img, spacing=40, color=(255, 255, 255, 6)):
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    for x in range(0, img.size[0], spacing):
        d.line([(x, 0), (x, img.size[1])], fill=color, width=1)
    for y in range(0, img.size[1], spacing):
        d.line([(0, y), (img.size[0], y)], fill=color, width=1)
    return Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")

def base_canvas(w, h, with_grid=True):
    img = gradient_bg(w, h)
    # Orange glow top-left
    glow = radial_glow(w, h, int(w * 0.15), int(h * 0.1), int(min(w, h) * 0.5), ACCENT, alpha=42)
    img = Image.alpha_composite(img.convert("RGBA"), glow).convert("RGB")
    # Cool glow bottom-right
    glow2 = radial_glow(w, h, int(w * 0.85), int(h * 0.9), int(min(w, h) * 0.55), (60, 100, 200), alpha=28)
    img = Image.alpha_composite(img.convert("RGBA"), glow2).convert("RGB")
    if with_grid:
        img = add_subtle_grid(img)
    return img


# =================================================================
# COVER: shared design for hero/cover images at multiple sizes
# =================================================================
def make_cover(w, h, title_size=None, sub_size=None, padding=None, mode="hero"):
    """
    Hero cover with title, subtitle, priority-chain visual hint.
    mode: "hero" (full design) or "wide" (devto-style 1000x420)
    """
    img = base_canvas(w, h)
    draw = ImageDraw.Draw(img)

    pad = padding or int(min(w, h) * 0.07)
    ts = title_size or int(h * 0.13)
    ss = sub_size or int(h * 0.045)

    # Brand
    draw_brand_strip(img, draw, pad, pad)

    # Headline
    title1 = "Six ways to authenticate."
    title2 = "One silently overrides your subscription."

    f_title = font(F_BLACK, ts)
    # adjust if text overflows
    while text_w(draw, title2, f_title) > w - pad * 2 and ts > 24:
        ts -= 2
        f_title = font(F_BLACK, ts)

    title_y = pad + 60
    draw.text((pad, title_y), title1, font=f_title, fill=TEXT)
    title_y2 = title_y + int(ts * 1.05)
    # second line — accent-colored "silently"
    pre = "One "
    word = "silently"
    post = " overrides your subscription."
    x = pad
    draw.text((x, title_y2), pre, font=f_title, fill=TEXT)
    x += text_w(draw, pre, f_title)
    draw.text((x, title_y2), word, font=f_title, fill=ACCENT)
    x += text_w(draw, word, f_title)
    # if the rest doesn't fit, wrap "your subscription." to the next line
    if x + text_w(draw, post, f_title) > w - pad:
        draw.text((x, title_y2), " overrides", font=f_title, fill=TEXT)
        title_y3 = title_y2 + int(ts * 1.05)
        draw.text((pad, title_y3), "your subscription.", font=f_title, fill=TEXT)
        sub_y = title_y3 + int(ts * 1.2)
    else:
        draw.text((x, title_y2), post, font=f_title, fill=TEXT)
        sub_y = title_y2 + int(ts * 1.4)

    # Subtitle
    f_sub = font(F_REG, ss)
    sub = "A cross-platform installer for Claude Code authentication —"
    sub2 = "Bash + Batch + PowerShell. MIT licensed."
    draw.text((pad, sub_y), sub, font=f_sub, fill=MUTED)
    draw.text((pad, sub_y + int(ss * 1.3)), sub2, font=f_sub, fill=MUTED)

    # Footer / CTA
    f_url = font(F_MONO_B, max(14, int(ss * 0.78)))
    url = "github.com/anilatambharii/claude-auth-setup"
    draw.text((pad, h - pad - 24), url, font=f_url, fill=ACCENT)

    return img


# =================================================================
# Priority chain diagram
# =================================================================
def make_priority_chain(w=1600, h=1000):
    img = base_canvas(w, h)
    draw = ImageDraw.Draw(img)
    pad = 80

    draw_brand_strip(img, draw, pad, pad)

    f_title = font(F_BLACK, 64)
    f_sub   = font(F_REG, 26)
    draw.text((pad, pad + 50), "Claude Code auth resolution order", font=f_title, fill=TEXT)
    draw.text((pad, pad + 130), "Highest priority wins. Subscription is dead last.", font=f_sub, fill=MUTED)

    methods = [
        ("1", "Cloud provider credentials",     "AWS Bedrock · Vertex AI · Foundry",  False),
        ("2", "ANTHROPIC_AUTH_TOKEN",           "LLM gateways and proxies",            False),
        ("3", "ANTHROPIC_API_KEY",              "The silent footgun",                  True),
        ("4", "apiKeyHelper script",            "Custom credential resolver",          False),
        ("5", "CLAUDE_CODE_OAUTH_TOKEN",        "CI / headless environments",          False),
        ("6", "Subscription OAuth",             "What most Pro users actually want",   False),
    ]

    row_h = 110
    row_inner_h = 96
    start_y = pad + 220
    f_num   = font(F_BLACK, 48)
    f_name  = font(F_BOLD, 32)
    f_name_mono = font(F_MONO_B, 28)
    f_desc  = font(F_REG, 22)
    f_tag   = font(F_BOLD, 18)

    for i, (num, name, desc, danger) in enumerate(methods):
        y = start_y + i * row_h
        # row background
        bg_col = (40, 28, 22) if danger else CARD
        rounded_box(draw, (pad, y, w - pad, y + row_inner_h), 12, fill=bg_col, outline=ACCENT if danger else BORDER, width=2 if danger else 1)
        # number
        draw.text((pad + 30, y + 22), num, font=f_num, fill=ACCENT if danger else MUTED)
        # name (mono if it's an env var)
        nf = f_name_mono if (name.isupper() or name.startswith("ANTHROPIC") or name.startswith("CLAUDE") or name.startswith("apiKey")) else f_name
        draw.text((pad + 130, y + 18), name, font=nf, fill=TEXT)
        # description
        draw.text((pad + 130, y + 58), desc, font=f_desc, fill=ACCENT if danger else MUTED)
        # right side tag
        tag_y = y + 32
        if i == 5:
            tag = "WHAT YOU PROBABLY WANT"
            tw = text_w(draw, tag, f_tag)
            rounded_box(draw, (w - pad - tw - 32, tag_y, w - pad - 16, tag_y + 32), 6, fill=(20, 50, 30), outline=SUCCESS, width=1)
            draw.text((w - pad - tw - 24, tag_y + 6), tag, font=f_tag, fill=SUCCESS)
        if danger:
            tag = "OVERRIDES SUBSCRIPTION"
            tw = text_w(draw, tag, f_tag)
            rounded_box(draw, (w - pad - tw - 32, tag_y, w - pad - 16, tag_y + 32), 6, fill=(60, 25, 20), outline=WARN, width=1)
            draw.text((w - pad - tw - 24, tag_y + 6), tag, font=f_tag, fill=WARN)

    # Footer
    f_foot = font(F_MONO_B, 22)
    draw.text((pad, h - 80), "github.com/anilatambharii/claude-auth-setup", font=f_foot, fill=ACCENT)
    return img


# =================================================================
# Quote card (square)
# =================================================================
def make_quote_card(w=1200, h=1200):
    img = base_canvas(w, h)
    draw = ImageDraw.Draw(img)
    pad = 90

    draw_brand_strip(img, draw, pad, pad)

    f_q     = font(F_BLACK, 64)
    f_attr  = font(F_REG, 28)
    f_label = font(F_BOLD, 22)

    # Big orange opening quote
    f_quote_mark = font(F_BLACK, 220)
    draw.text((pad - 12, pad + 70), "“", font=f_quote_mark, fill=ACCENT)

    # Quote text — split into lines manually
    lines = [
        "My Anthropic Console bill",
        "went from $0 to $47 last",
        "month and I don’t know",
        "why.",
    ]
    y = pad + 280
    for line in lines:
        draw.text((pad, y), line, font=f_q, fill=TEXT)
        y += int(f_q.size * 1.05)

    # Attribution
    draw.text((pad, y + 30), "— the most common Claude Code support thread", font=f_attr, fill=MUTED)

    # Diagnosis row at bottom
    diag_y = h - pad - 180
    rounded_box(draw, (pad, diag_y, w - pad, diag_y + 120), 14, fill=CARD, outline=BORDER, width=1)
    draw.text((pad + 24, diag_y + 18), "DIAGNOSIS", font=f_label, fill=ACCENT)
    f_diag = font(F_MONO_B, 26)
    draw.text((pad + 24, diag_y + 56), "$ env | grep ANTHROPIC_API_KEY", font=f_diag, fill=TEXT)

    f_url = font(F_MONO_B, 22)
    draw.text((pad, h - pad - 8), "github.com/anilatambharii/claude-auth-setup", font=f_url, fill=ACCENT)
    return img


# =================================================================
# Terminal-style "test pass" image
# =================================================================
def make_terminal_card(w=1400, h=900):
    img = base_canvas(w, h, with_grid=False)
    draw = ImageDraw.Draw(img)
    pad = 90

    draw_brand_strip(img, draw, pad, pad)

    f_title = font(F_BLACK, 56)
    f_sub   = font(F_REG, 24)
    draw.text((pad, pad + 50), "37 of 38 tests passing.", font=f_title, fill=TEXT)
    draw.text((pad, pad + 120), "The one failure is in the test suite, not the installer.", font=f_sub, fill=MUTED)

    # Terminal card
    tx, ty = pad, pad + 200
    tw, th = w - pad * 2, h - ty - pad - 20
    rounded_box(draw, (tx, ty, tx + tw, ty + th), 14, fill=(8, 10, 14), outline=BORDER, width=1)
    # Mac-style window dots
    for i, c in enumerate([(255, 95, 86), (255, 189, 46), (39, 201, 63)]):
        cx = tx + 24 + i * 24
        draw.ellipse((cx, ty + 18, cx + 14, ty + 32), fill=c)
    f_term_title = font(F_MONO_B, 18)
    draw.text((tx + tw // 2 - 90, ty + 18), "bash test-suite.sh", font=f_term_title, fill=MUTED)

    # Lines of "output"
    f_mono = font(F_MONO, 20)
    f_mono_b = font(F_MONO_B, 20)
    lx = tx + 32
    ly = ty + 64
    line_h = 28

    output = [
        ("$ bash test-suite.sh",                                           TEXT,    f_mono_b),
        ("",                                                               TEXT,    f_mono),
        ("  Environment Variable Safety",                                  MUTED,   f_mono),
        ("  ✓ PASS  Can read existing environment variables",              SUCCESS, f_mono),
        ("  ✓ PASS  User's ANTHROPIC_API_KEY untouched",                   SUCCESS, f_mono),
        ("  ✓ PASS  User's ANTHROPIC_AUTH_TOKEN untouched",                SUCCESS, f_mono),
        ("",                                                               TEXT,    f_mono),
        ("  Cross-Platform Compatibility",                                 MUTED,   f_mono),
        ("  ✓ PASS  Unix/Linux script exists",                             SUCCESS, f_mono),
        ("  ✓ PASS  Windows script exists",                                SUCCESS, f_mono),
        ("  ✓ PASS  .gitattributes configured for line endings",           SUCCESS, f_mono),
        ("",                                                               TEXT,    f_mono),
        ("  ───────────────────────────────────",                          MUTED,   f_mono),
        ("  Tests Run:    38",                                             TEXT,    f_mono_b),
        ("  Tests Passed: 37",                                             SUCCESS, f_mono_b),
        ("  Tests Failed: 1",                                              WARN,    f_mono_b),
    ]

    # Vertical-fit guard: ensure content stays within the terminal frame
    max_y = ty + th - 24
    for txt, col, fnt in output:
        if ly + line_h > max_y:
            break
        draw.text((lx, ly), txt, font=fnt, fill=col)
        ly += line_h

    return img


# =================================================================
# Feature card (square) — what the installer does
# =================================================================
def make_feature_card(w=1200, h=1200):
    img = base_canvas(w, h)
    draw = ImageDraw.Draw(img)
    pad = 80

    draw_brand_strip(img, draw, pad, pad)

    f_title = font(F_BLACK, 64)
    draw.text((pad, pad + 50), "What it does.", font=f_title, fill=TEXT)
    f_sub = font(F_REG, 24)
    draw.text((pad, pad + 130), "Five interactive steps. Zero surprises.", font=f_sub, fill=MUTED)

    items = [
        ("01", "Detects existing auth state", "before changing anything"),
        ("02", "Asks one branching question", "\"do you have a subscription?\""),
        ("03", "Validates API key format", "sk-ant-* prefix and length"),
        ("04", "Backs up shell config", "timestamped, with rollback printed"),
        ("05", "Idempotent + cross-platform", "macOS · Linux · Windows"),
    ]

    f_num = font(F_BLACK, 56)
    f_name = font(F_BOLD, 30)
    f_desc = font(F_REG, 22)

    start_y = pad + 240
    row = 150

    for i, (n, name, desc) in enumerate(items):
        y = start_y + i * row
        rounded_box(draw, (pad, y, w - pad, y + row - 24), 14, fill=CARD, outline=BORDER, width=1)
        draw.text((pad + 28, y + 22), n, font=f_num, fill=ACCENT)
        draw.text((pad + 130, y + 26), name, font=f_name, fill=TEXT)
        draw.text((pad + 130, y + 70), desc, font=f_desc, fill=MUTED)

    f_url = font(F_MONO_B, 22)
    draw.text((pad, h - pad - 8), "github.com/anilatambharii/claude-auth-setup", font=f_url, fill=ACCENT)
    return img


# =================================================================
# Render all
# =================================================================
def main():
    out = os.path.dirname(os.path.abspath(__file__))

    targets = []

    # Hero covers — single design at multiple sizes
    print("Generating cover images...")
    medium      = make_cover(1400, 787)
    medium.save(os.path.join(out, "cover-medium.png"))
    targets.append("cover-medium.png  (1400x787)")

    linkedin_share = make_cover(1200, 627)
    linkedin_share.save(os.path.join(out, "cover-linkedin.png"))
    targets.append("cover-linkedin.png  (1200x627)")

    x_thread    = make_cover(1600, 900)
    x_thread.save(os.path.join(out, "cover-x.png"))
    targets.append("cover-x.png  (1600x900)")

    devto       = make_cover(1000, 420, title_size=58, sub_size=22, padding=44)
    devto.save(os.path.join(out, "cover-devto.png"))
    targets.append("cover-devto.png  (1000x420)")

    substack    = make_cover(1200, 630)
    substack.save(os.path.join(out, "cover-substack.png"))
    targets.append("cover-substack.png  (1200x630)")

    reddit      = make_cover(1200, 630)
    reddit.save(os.path.join(out, "cover-reddit.png"))
    targets.append("cover-reddit.png  (1200x630)")

    # Detailed / inline visuals
    print("Generating priority chain diagram...")
    make_priority_chain(1600, 1120).save(os.path.join(out, "diagram-priority-chain.png"))
    targets.append("diagram-priority-chain.png  (1600x1120)")

    print("Generating quote card...")
    make_quote_card(1200, 1200).save(os.path.join(out, "card-quote-bill.png"))
    targets.append("card-quote-bill.png  (1200x1200)")

    print("Generating terminal card...")
    make_terminal_card(1400, 980).save(os.path.join(out, "card-terminal-tests.png"))
    targets.append("card-terminal-tests.png  (1400x980)")

    print("Generating feature card...")
    make_feature_card(1200, 1200).save(os.path.join(out, "card-features.png"))
    targets.append("card-features.png  (1200x1200)")

    print("\nDone. Generated:")
    for t in targets:
        print("  -", t)


if __name__ == "__main__":
    main()
