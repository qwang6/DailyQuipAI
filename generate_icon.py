#!/usr/bin/env python3
"""
Professional DailyQuipAI App Icon Generator
Design: Modern knowledge card with glass morphism effects
"""
from PIL import Image, ImageDraw, ImageFont
import os
import math

def create_icon(size, filename):
    """
    Create professional app icon with:
    - Purple to indigo gradient background
    - Glass morphism card design
    - Minimalist book/knowledge symbol
    - Premium quality suitable for App Store
    """

    # Create base image
    img = Image.new('RGB', (size, size))
    draw = ImageDraw.Draw(img)

    # Background: Vibrant purple-indigo radial gradient
    center_x, center_y = size // 2, size // 2
    max_radius = math.sqrt(center_x**2 + center_y**2)

    for y in range(size):
        for x in range(size):
            dx, dy = x - center_x, y - center_y
            distance = math.sqrt(dx*dx + dy*dy)
            ratio = min(distance / max_radius, 1.0)

            # Premium gradient: #8B5CF6 (vibrant purple) to #6366F1 (indigo)
            r = int(139 - ratio * 40)
            g = int(92 + ratio * 10)
            b = int(246 - ratio * 44)

            draw.point((x, y), (r, g, b))

    # Draw glassmorphism card
    margin = int(size * 0.18)
    card_rect = [margin, margin, size - margin, size - margin]
    radius = int(size * 0.22)

    # Card shadow (soft)
    for i in range(6, 0, -1):
        shadow_alpha = 25 - i * 3
        shadow_color = (20, 20, 50)
        overlay = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        shadow_draw = ImageDraw.Draw(overlay)
        shadow_draw.rounded_rectangle(
            [margin + i, margin + i, size - margin + i, size - margin + i],
            radius,
            fill=(*shadow_color, shadow_alpha)
        )
        img.paste(overlay, (0, 0), overlay)

    # Glass card with subtle white overlay
    card_overlay = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    card_draw = ImageDraw.Draw(card_overlay)

    # Card base (semi-transparent white)
    card_draw.rounded_rectangle(
        card_rect,
        radius,
        fill=(255, 255, 255, 35)
    )

    # Light reflection on top (gradient)
    light_height = int((size - 2 * margin) * 0.4)
    for i in range(light_height):
        alpha = int(25 * (1 - i / light_height))
        card_draw.line(
            [(margin, margin + i), (size - margin, margin + i)],
            fill=(255, 255, 255, alpha)
        )

    # Card border (bright white)
    card_draw.rounded_rectangle(
        card_rect,
        radius,
        outline=(255, 255, 255, 140),
        width=max(2, size // 250)
    )

    img.paste(card_overlay, (0, 0), card_overlay)

    # Draw knowledge symbol (stylized book/card stack)
    symbol_overlay = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    symbol_draw = ImageDraw.Draw(symbol_overlay)

    # Card stack (3 layered cards)
    card_w = int(size * 0.32)
    card_h = int(size * 0.22)
    card_center_x = size // 2
    card_center_y = int(size * 0.38)

    # Draw 3 stacked cards with offset
    cards = [
        {"offset": (-6, 4), "alpha": 80},   # Back card
        {"offset": (-3, 2), "alpha": 120},  # Middle card
        {"offset": (0, 0), "alpha": 220}    # Front card
    ]

    for i, card_props in enumerate(cards):
        offset_x, offset_y = card_props["offset"]
        if size < 100:  # Scale offsets for small sizes
            offset_x = offset_x // 2
            offset_y = offset_y // 2

        c_x1 = card_center_x - card_w//2 + offset_x
        c_y1 = card_center_y - card_h//2 + offset_y
        c_x2 = card_center_x + card_w//2 + offset_x
        c_y2 = card_center_y + card_h//2 + offset_y

        # Card background
        symbol_draw.rounded_rectangle(
            [c_x1, c_y1, c_x2, c_y2],
            int(size * 0.04),
            fill=(255, 255, 255, card_props["alpha"])
        )

        # Only draw lines on front card
        if i == 2:
            # Three horizontal lines (knowledge/text lines)
            line_h = max(2, size // 300)
            line_margin_x = int(card_w * 0.18)
            line_y_start = c_y1 + int(card_h * 0.3)
            line_spacing = int(card_h * 0.23)

            for j in range(3):
                y_pos = line_y_start + j * line_spacing
                # Line width variation for visual interest
                line_w = card_w - 2 * line_margin_x
                if j == 2:  # Last line shorter
                    line_w = int(line_w * 0.7)

                symbol_draw.rounded_rectangle(
                    [c_x1 + line_margin_x, y_pos,
                     c_x1 + line_margin_x + line_w, y_pos + line_h],
                    line_h // 2,
                    fill=(99, 102, 241, 200)  # Indigo accent
                )

    img.paste(symbol_overlay, (0, 0), symbol_overlay)

    # Add brand text "DQ" (only for larger sizes)
    if size >= 40:  # Skip text for very small icons
        try:
            # Try SF Pro Display Bold (macOS system font)
            font_size = max(10, int(size * 0.16))  # Minimum 10pt font
            font_paths = [
                "/System/Library/Fonts/SF-Pro-Display-Bold.otf",
                "/System/Library/Fonts/SF-Pro.ttf",
                "/System/Library/Fonts/Helvetica.ttc"
            ]

            font = None
            for path in font_paths:
                try:
                    font = ImageFont.truetype(path, font_size)
                    break
                except:
                    continue

            if not font:
                font = ImageFont.load_default()

        except:
            font = ImageFont.load_default()

        text = "DQ"
        text_overlay = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        text_draw = ImageDraw.Draw(text_overlay)

        try:
            bbox = text_draw.textbbox((0, 0), text, font=font)
            text_w = bbox[2] - bbox[0]
            text_h = bbox[3] - bbox[1]

            text_x = (size - text_w) // 2
            text_y = int(size * 0.66)

            # Text shadow (subtle depth)
            shadow_offset = max(1, size // 350)
            for i in range(3, 0, -1):
                text_draw.text(
                    (text_x + i * shadow_offset, text_y + i * shadow_offset),
                    text,
                    font=font,
                    fill=(0, 0, 40, 60)
                )

            # Main text (crisp white)
            text_draw.text((text_x, text_y), text, font=font, fill=(255, 255, 255, 255))

            img.paste(text_overlay, (0, 0), text_overlay)
        except:
            # If text rendering fails, skip it
            pass

    # Add subtle sparkle accents (premium feel)
    sparkle_overlay = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    sparkle_draw = ImageDraw.Draw(sparkle_overlay)

    sparkles = [
        (int(size * 0.22), int(size * 0.22)),
        (int(size * 0.78), int(size * 0.28)),
        (int(size * 0.82), int(size * 0.72)),
    ]

    sparkle_r = max(1, size // 150)
    for sx, sy in sparkles:
        # Glow
        for r in range(sparkle_r * 3, sparkle_r, -1):
            alpha = int(60 * (1 - (r - sparkle_r) / (sparkle_r * 2)))
            sparkle_draw.ellipse(
                [sx - r, sy - r, sx + r, sy + r],
                fill=(255, 255, 255, alpha)
            )
        # Core
        sparkle_draw.ellipse(
            [sx - sparkle_r, sy - sparkle_r, sx + sparkle_r, sy + sparkle_r],
            fill=(255, 255, 255, 200)
        )

    img.paste(sparkle_overlay, (0, 0), sparkle_overlay)

    # Save high-quality PNG
    img.save(filename, 'PNG', optimize=True, quality=100)
    print(f"✓ {size}x{size}")


# All required iOS icon sizes
SIZES = [
    1024,  # App Store (Required)
    180,   # iPhone App 60pt@3x
    167,   # iPad Pro App 83.5pt@2x
    152,   # iPad App 76pt@2x
    120,   # iPhone App 60pt@2x
    87,    # iPhone Settings 29pt@3x
    80,    # iPhone Spotlight 40pt@2x / iPad Settings 40pt@2x
    76,    # iPad App 76pt@1x
    60,    # iPhone Spotlight 40pt@3x
    58,    # iPhone Settings 29pt@2x / iPad Settings 29pt@2x
    40,    # iPhone Spotlight 40pt@1x / iPad Spotlight 40pt@1x
    29,    # iPhone Settings 29pt@1x / iPad Settings 29pt@1x
    20,    # iPad Notification 20pt@1x
]

def main():
    # Ensure we're in the right directory
    os.chdir("/Users/qianwang/Downloads/my_projects/DailyQuipAI")

    icon_dir = "DailyQuipAI/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(icon_dir, exist_ok=True)

    print("🎨 DailyQuipAI App Icon Generator")
    print("=" * 50)
    print("Design: Glass morphism knowledge card")
    print("Colors: Purple-Indigo gradient (#8B5CF6 → #6366F1)")
    print("=" * 50)
    print("\nGenerating icons:")

    for size in SIZES:
        filename = f"{icon_dir}/icon_{size}x{size}.png"
        create_icon(size, filename)

    print("\n✅ All icons generated successfully!")
    print(f"📁 Location: {icon_dir}/")
    print("\n📱 Design features:")
    print("   • Professional glass morphism effect")
    print("   • Stacked knowledge cards symbol")
    print("   • Purple-indigo premium gradient")
    print("   • 'DQ' branding with depth")
    print("   • Sparkle accents for sophistication")
    print("\n⚠️  Next: Update Contents.json and rebuild in Xcode")

if __name__ == "__main__":
    main()
