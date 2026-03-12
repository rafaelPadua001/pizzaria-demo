import os

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
