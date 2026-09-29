import os
import jwt
from jwt import PyJWKClient
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Captain Vision AI Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

security = HTTPBearer()

# Replace with your project URL, or pass via $env:SUPABASE_URL
SUPABASE_URL = os.getenv("SUPABASE_URL", "https://your-project-ref.supabase.co")
JWKS_URL = os.getenv("SUPABASE_JWKS_URL", f"{SUPABASE_URL}/auth/v1/.well-known/jwks.json")

jwks_client = PyJWKClient(JWKS_URL)

def verify_supabase_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    try:
        # Resolves the correct ECC public key automatically matching the key ID
        signing_key = jwks_client.get_signing_key_from_jwt(token)
        payload = jwt.decode(
            token,
            signing_key.key,
            algorithms=["ES256", "HS256"],
            options={"verify_aud": False}
        )
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token: missing subject"
            )
        return {"user_id": user_id, "role": payload.get("role")}
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Session token has expired"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token validation failed: {str(e)}"
        )

@app.get("/health")
async def health_check():
    return {"status": "ok"}

@app.post("/api/v1/analyze-clip")
async def analyze_clip(data: dict, user: dict = Depends(verify_supabase_token)):
    return {
        "status": "success",
        "captain_id": user["user_id"],
        "message": "Token verified via Supabase ECC JWKS",
        "processed_by": "GPU_Cluster",
        "metrics": {
            "player_tracking": True,
            "ball_speed_kmh": 84.5
        }
    }
