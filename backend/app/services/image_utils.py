def resolve_image_url(image: str | None) -> str | None:
    if not image:
        return None
    if image.startswith("http://") or image.startswith("https://"):
        return image
    return f"/uploads/products/{image}"
