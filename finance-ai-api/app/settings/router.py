from fastapi import status, Depends
from fastapi import APIRouter

from app.dependencies import get_current_user
from app.models.user import User
from app.settings.schema import ProfileResponse
from app.schemas.common import ResponseModel

router = APIRouter(prefix='/settings', tags=["Settings"])


@router.get("/", status_code=status.HTTP_200_OK, response_model=ResponseModel[ProfileResponse])
async def profile_info(current_user: User = Depends(get_current_user)):
    """Get current user's profile information."""

    return ResponseModel(
        success=True,
        message="Profile retrieved successfully",
        data=ProfileResponse(
            email=current_user.email,
            full_name=current_user.full_name,
            picture=current_user.picture,
            provider=current_user.provider,
            email_verified=current_user.email_verified,
            created_at=current_user.created_at.isoformat(),
        )
    )
