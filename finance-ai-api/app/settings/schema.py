from pydantic import BaseModel, EmailStr
from typing import Optional


class ProfileResponse(BaseModel):
    """User profile response schema."""
    email: EmailStr
    full_name: Optional[str] = None
    picture: Optional[str] = None
    provider: str
    email_verified: bool
    created_at: str
