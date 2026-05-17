from pathlib import Path

from PIL import Image, ImageDraw


def main() -> None:
    size = 1024
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    margin = 64
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=220,
        fill=(255, 215, 0, 255),
    )

    draw.ellipse(
        [220, 220, 804, 804],
        fill=(255, 244, 210, 255),
    )

    draw.rectangle([484, 300, 540, 744], fill=(34, 34, 34, 255))
    draw.arc([360, 300, 660, 520], start=18, end=162, fill=(34, 34, 34, 255), width=56)
    draw.arc([360, 520, 660, 744], start=198, end=342, fill=(34, 34, 34, 255), width=56)

    out_main = Path("assets/icons/app_icon.png")
    out_linux = Path("linux/runner/resources/app_icon.png")
    out_main.parent.mkdir(parents=True, exist_ok=True)
    out_linux.parent.mkdir(parents=True, exist_ok=True)

    image.save(out_main)
    image.resize((256, 256), Image.Resampling.LANCZOS).save(out_linux)


if __name__ == "__main__":
    main()
