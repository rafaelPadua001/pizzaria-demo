from datetime import datetime

from pydantic import BaseModel


class AdminLoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str


class AdminResponse(BaseModel):
    id: int
    username: str

    class Config:
        orm_mode = True


class CategoryBase(BaseModel):
    name: str
    title: str | None = None
    description: str | None = None
    icon: str | None = None
    image_url: str | None = None
    slug: str
    order: int = 0
    is_active: bool = True


class CategoryCreate(CategoryBase):
    pass


class CategoryUpdate(BaseModel):
    name: str | None = None
    title: str | None = None
    description: str | None = None
    icon: str | None = None
    image_url: str | None = None
    slug: str | None = None
    order: int | None = None
    is_active: bool | None = None


class CategoryResponse(CategoryBase):
    id: int
    created_at: datetime
    updated_at: datetime | None = None

    class Config:
        orm_mode = True


class CategoryPublicResponse(BaseModel):
    id: int
    title: str | None = None
    description: str | None = None
    icon: str | None = None
    slug: str
    image_url: str | None = None

    class Config:
        orm_mode = True


class ProductPublicResponse(BaseModel):
    id: int
    name: str
    description: str | None = None
    price: float
    image_url: str | None = None

    class Config:
        orm_mode = True


class CategoryDetailResponse(BaseModel):
    id: int
    title: str | None = None
    description: str | None = None
    slug: str
    products: list[ProductPublicResponse]

    class Config:
        orm_mode = True


class ProductBase(BaseModel):
    name: str
    description: str | None = None
    price: float
    image_url: str | None = None
    is_active: bool = True
    category_id: int


class ProductCreate(ProductBase):
    pass


class ProductUpdate(BaseModel):
    name: str | None = None
    description: str | None = None
    price: float | None = None
    image_url: str | None = None
    is_active: bool | None = None
    category_id: int | None = None


class ProductResponse(ProductBase):
    id: int

    class Config:
        orm_mode = True


class OrderItemCreate(BaseModel):
    product_id: int | None = None
    product_name: str
    quantity: int = 1
    unit_price: float


class OrderCreate(BaseModel):
    customer_name: str | None = None
    customer_phone: str | None = None
    total_amount: float | None = None
    items: list[OrderItemCreate]


class OrderItemResponse(BaseModel):
    id: int
    product_id: int | None = None
    product_name: str
    quantity: int
    unit_price: float

    class Config:
        orm_mode = True


class OrderResponse(BaseModel):
    id: int
    customer_name: str | None = None
    customer_phone: str | None = None
    total_amount: float
    status: str
    created_at: datetime
    items: list[OrderItemResponse]

    class Config:
        orm_mode = True


class PageSectionBase(BaseModel):
    name: str
    title: str | None = None
    subtitle: str | None = None
    content: str | None = None
    image_url: str | None = None
    link: str | None = None
    order: int = 0


class PageSectionCreate(PageSectionBase):
    pass


class PageSectionUpdate(BaseModel):
    name: str | None = None
    title: str | None = None
    subtitle: str | None = None
    content: str | None = None
    image_url: str | None = None
    link: str | None = None
    order: int | None = None


class PageSectionResponse(PageSectionBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True


class PageBase(BaseModel):
    slug: str
    title: str | None = None
    content: str | None = None


class PageCreate(PageBase):
    pass


class PageUpdate(BaseModel):
    slug: str | None = None
    title: str | None = None
    content: str | None = None


class PageResponse(PageBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True
