import os
import pytest
from utils.booker_helper import BookHelper


@pytest.fixture(scope="session", autouse=True)
def base_url():
    """Base URL fixture. Autouse for the test session. Can be overridden via API_BASE_URL env var."""
    return os.getenv("API_BASE_URL", "https://api.dev.example.com")


@pytest.fixture(scope="session", autouse=True)
def auth_token():
    """Auth token fixture. Autouse for the test session. Can be overridden via API_AUTH_TOKEN env var."""
    return os.getenv("API_AUTH_TOKEN", "test-token-123")


@pytest.fixture
def headers(auth_token):
    """Return default headers for API requests."""
    return {
        "Authorization": f"Bearer {auth_token}",
        "Accept": "application/json",
        "Content-Type": "application/json",
    }


@pytest.fixture(scope="session")
def booker_client():
    client = BookHelper()
    # Auth once per session (SOLID: D - inject client)
    token = client.authenticate()
    assert token, "Authentication failed - check credentials"
    yield client

@pytest.fixture
def sample_booking_payload():
    """Reusable payload factory (encapsulation)"""
    return {
        "firstname": "Sowmya",
        "lastname": "TestUser",
        "totalprice": 150,
        "depositpaid": True,
        "bookingdates": {
            "checkin": "2026-03-01",
            "checkout": "2026-03-10"
        },
        "additionalneeds": "Breakfast"
    }