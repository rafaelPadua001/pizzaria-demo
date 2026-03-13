import os
from urllib.parse import urlparse

import cloudinary
import cloudinary.uploader


cloudinary.config(
    cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
    api_key=os.getenv("CLOUDINARY_API_KEY"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET"),
)


def upload_product_image(file, restaurant_name: str) -> str:
    result = cloudinary.uploader.upload(
        file.file,
        folder=f"restaurant/{restaurant_name}",
        resource_type="image",
    )
    return result["secure_url"]


def upload_product_image_from_path(file_path: str, restaurant_name: str) -> str:
    result = cloudinary.uploader.upload(
        file_path,
        folder=f"restaurant/{restaurant_name}",
        resource_type="image",
    )
    return result["secure_url"]


def get_public_id_from_url(url: str) -> str | None:
    if not url or not isinstance(url, str):
        return None
    try:
        parsed = urlparse(url)
    except Exception:
        return None
    path = parsed.path or ""
    if "/upload/" not in path:
        return None
    public_path = path.split("/upload/", 1)[1].lstrip("/")
    if not public_path:
        return None
    segments = public_path.split("/")
    if segments and segments[0].startswith("v") and segments[0][1:].isdigit():
        public_path = "/".join(segments[1:])
    public_path = os.path.splitext(public_path)[0]
    return public_path or None


def delete_cloudinary_image(url: str) -> None:
    public_id = get_public_id_from_url(url)
    if not public_id:
        return
    cloudinary.uploader.destroy(public_id, resource_type="image")
