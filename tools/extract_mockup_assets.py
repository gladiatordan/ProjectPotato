#!/usr/bin/env python3
"""
First-pass raster asset extraction from the flattened ProjectPotato UI mockup.

These crop boxes are tuned for the current 1536x1024 mockup and are expected to
be adjusted over time. They are intentionally kept together near the top of the
file so future coordinate nudges stay easy and obvious.
"""

from __future__ import annotations

from collections import deque
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageEnhance, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT / "resources" / "source"
ASSET_ROOT = ROOT / "resources" / "assets"
MOCKUP_PATH = SOURCE_ROOT / "projectpotato_mockup.png"
ASSET_INFO_PATH = SOURCE_ROOT / "asset_info.png"


# Crop boxes for the 1536x1024 flattened mockup.
HEADER_FULL_BOX = (10, 12, 1523, 250)

WINDOW_CONTROLS = {
    "minimize_normal.png": (1346, 28, 1408, 73),
    "maximize_normal.png": (1409, 28, 1470, 73),
    "close_normal.png": (1470, 28, 1526, 73),
}

SIDEBAR_FULL = {
    "launcher_active_full.png": (30, 272, 279, 343),
    "workers_normal_full.png": (30, 361, 279, 432),
    "settings_normal_full.png": (30, 450, 279, 521),
}

SIDEBAR_BLANK_PATCHES = {
    "tab_active_blank.png": {
        "source": "launcher_active_full.png",
        "fill_box": (18, 10, 232, 56),
        "tile_box": (222, 18, 234, 30),
    },
    "tab_normal_blank.png": {
        "source": "workers_normal_full.png",
        "fill_box": (18, 10, 232, 56),
        "tile_box": (222, 18, 234, 30),
    },
}

BUTTONS = {
    "launch_normal.png": (1218, 384, 1324, 421),
    "update_normal.png": (1355, 440, 1454, 476),
}

CHECKBOXES = {
    "empty.png": (342, 339, 364, 362),
    "checked.png": (887, 390, 910, 414),
}

DROPDOWN_NORMAL_BOX = (591, 383, 816, 420)

MAIN_BORDER_BOXES = {
    "tl.png": (0, 0, 64, 64),
    "t.png": (672, 17, 864, 33),
    "tr.png": (1472, 0, 1536, 64),
    "l.png": (15, 430, 31, 622),
    "c.png": (728, 686, 808, 766),
    "r.png": (1504, 430, 1520, 622),
    "bl.png": (0, 960, 64, 1024),
    "b.png": (672, 987, 864, 1003),
    "br.png": (1472, 960, 1536, 1024),
}

PANEL_BORDER_BOXES = {
    "tl.png": (309, 269, 349, 309),
    "t.png": (874, 274, 1002, 290),
    "tr.png": (1449, 269, 1489, 309),
    "l.png": (311, 487, 327, 615),
    "c.png": (781, 714, 845, 778),
    "r.png": (1473, 487, 1489, 615),
    "bl.png": (309, 686, 349, 726),
    "b.png": (869, 710, 997, 726),
    "br.png": (1449, 686, 1489, 726),
}


NORMAL_GLOW = (84, 208, 255, 88)
CLOSE_GLOW = (255, 122, 72, 118)
TRANSPARENCY_LUMA_THRESHOLD = 18


def main() -> int:
    if not MOCKUP_PATH.exists():
        print(
            "ERROR: Expected mockup source at "
            f"'{MOCKUP_PATH.relative_to(ROOT)}'. "
            "Copy the flattened mockup there and rerun the extractor."
        )
        return 1

    ensure_directories()
    generated_paths: list[Path] = []

    with Image.open(MOCKUP_PATH) as mockup_image:
        mockup = mockup_image.convert("RGBA")

        generated_paths.append(save_crop(mockup, HEADER_FULL_BOX, ASSET_ROOT / "header" / "projectpotato_header_full.png"))

        generated_paths.extend(extract_window_controls(mockup))
        generated_paths.extend(extract_sidebar_assets(mockup))
        generated_paths.extend(extract_button_assets(mockup))
        generated_paths.extend(extract_checkbox_assets(mockup))
        generated_paths.append(
            save_transparent_crop(
                mockup,
                DROPDOWN_NORMAL_BOX,
                ASSET_ROOT / "inputs" / "dropdown_normal.png",
            )
        )
        generated_paths.extend(extract_border_assets(mockup, ASSET_ROOT / "borders" / "main", MAIN_BORDER_BOXES))
        generated_paths.extend(extract_border_assets(mockup, ASSET_ROOT / "borders" / "panel", PANEL_BORDER_BOXES))

    print_generated_paths(generated_paths)
    return 0


def ensure_directories() -> None:
    for directory in [
        ASSET_ROOT / "header",
        ASSET_ROOT / "window_controls",
        ASSET_ROOT / "borders" / "main",
        ASSET_ROOT / "borders" / "panel",
        ASSET_ROOT / "sidebar",
        ASSET_ROOT / "buttons",
        ASSET_ROOT / "checkboxes",
        ASSET_ROOT / "inputs",
    ]:
        directory.mkdir(parents=True, exist_ok=True)


def save_crop(image: Image.Image, box: tuple[int, int, int, int], output_path: Path) -> Path:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    image.crop(box).save(output_path)
    return output_path


def save_transparent_crop(
    image: Image.Image,
    box: tuple[int, int, int, int],
    output_path: Path,
) -> Path:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    cropped = image.crop(box).convert("RGBA")
    make_outer_background_transparent(cropped)
    cropped.save(output_path)
    return output_path


def extract_window_controls(mockup: Image.Image) -> list[Path]:
    output_directory = ASSET_ROOT / "window_controls"
    generated: list[Path] = []

    for file_name, box in WINDOW_CONTROLS.items():
        normal_path = output_directory / file_name
        normal_image = mockup.crop(box).convert("RGBA")
        make_outer_background_transparent(normal_image)
        normal_image.save(normal_path)
        generated.append(normal_path)

        hover_path = output_directory / file_name.replace("_normal", "_hover")
        hover_glow = CLOSE_GLOW if file_name.startswith("close_") else NORMAL_GLOW
        create_hover_variant(normal_image, hover_glow).save(hover_path)
        generated.append(hover_path)

    return generated


def extract_sidebar_assets(mockup: Image.Image) -> list[Path]:
    output_directory = ASSET_ROOT / "sidebar"
    generated: list[Path] = []
    cached: dict[str, Image.Image] = {}

    for file_name, box in SIDEBAR_FULL.items():
        image = mockup.crop(box).convert("RGBA")
        output_path = output_directory / file_name
        image.save(output_path)
        cached[file_name] = image
        generated.append(output_path)

    for file_name, config in SIDEBAR_BLANK_PATCHES.items():
        source_image = cached[config["source"]].copy()
        blank_image = erase_sidebar_label(
            source_image,
            config["fill_box"],
            config["tile_box"],
        )
        output_path = output_directory / file_name
        blank_image.save(output_path)
        generated.append(output_path)

    return generated


def extract_button_assets(mockup: Image.Image) -> list[Path]:
    output_directory = ASSET_ROOT / "buttons"
    generated: list[Path] = []

    for file_name, box in BUTTONS.items():
        normal_path = output_directory / file_name
        normal_image = mockup.crop(box).convert("RGBA")
        make_outer_background_transparent(normal_image)
        normal_image.save(normal_path)
        generated.append(normal_path)

        hover_path = output_directory / file_name.replace("_normal", "_hover")
        create_hover_variant(normal_image, NORMAL_GLOW).save(hover_path)
        generated.append(hover_path)

    return generated


def extract_checkbox_assets(mockup: Image.Image) -> list[Path]:
    output_directory = ASSET_ROOT / "checkboxes"
    generated: list[Path] = []
    for file_name, box in CHECKBOXES.items():
        generated.append(save_transparent_crop(mockup, box, output_directory / file_name))
    return generated


def extract_border_assets(
    mockup: Image.Image,
    output_directory: Path,
    crop_boxes: dict[str, tuple[int, int, int, int]],
) -> list[Path]:
    generated: list[Path] = []
    for file_name, box in crop_boxes.items():
        output_path = output_directory / file_name
        generated.append(save_transparent_crop(mockup, box, output_path))
    return generated


def create_hover_variant(image: Image.Image, glow_color: tuple[int, int, int, int]) -> Image.Image:
    brightened = ImageEnhance.Brightness(image).enhance(1.12)
    alpha = brightened.getchannel("A")

    glow_mask = alpha.filter(ImageFilter.GaussianBlur(radius=5))
    glow_layer = Image.new("RGBA", brightened.size, glow_color)
    glow_layer.putalpha(glow_mask)

    combined = Image.alpha_composite(glow_layer, brightened)
    combined.putalpha(alpha)
    return combined


def erase_sidebar_label(
    image: Image.Image,
    fill_box: tuple[int, int, int, int],
    tile_box: tuple[int, int, int, int],
) -> Image.Image:
    left, top, right, bottom = fill_box
    tile = image.crop(tile_box)
    tile_width, tile_height = tile.size

    for y in range(top, bottom, tile_height):
        for x in range(left, right, tile_width):
            image.alpha_composite(tile, (x, y))

    return image


def make_outer_background_transparent(image: Image.Image) -> None:
    width, height = image.size
    rgba = image.load()
    visited: set[tuple[int, int]] = set()
    queue: deque[tuple[int, int]] = deque()

    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))

    while queue:
        x, y = queue.popleft()
        if (x, y) in visited or not (0 <= x < width and 0 <= y < height):
            continue
        visited.add((x, y))

        red, green, blue, alpha = rgba[x, y]
        luma = (red * 299 + green * 587 + blue * 114) // 1000
        if alpha == 0 or luma > TRANSPARENCY_LUMA_THRESHOLD:
            continue

        rgba[x, y] = (red, green, blue, 0)
        queue.extend(((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)))


def print_generated_paths(paths: Iterable[Path]) -> None:
    print("Generated assets:")
    for path in sorted(paths):
        print(path.relative_to(ROOT).as_posix())


if __name__ == "__main__":
    raise SystemExit(main())
