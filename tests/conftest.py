import os
import pytest
from utils.booker_helper import BookHelper

# Existing fixtures
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

# New fixtures required for API tests
@pytest.fixture(scope="session", autouse=True)
def base_url():
    """Base URL for the API under test. Can be overridden with env var API_BASE_URL."""
    return os.getenv("API_BASE_URL", "https://api.qa.example.com")


@pytest.fixture(scope="session", autouse=True)
def auth_token():
    """Auth token for Bearer auth. Can be overridden with env var API_AUTH_TOKEN."""
    return os.getenv("API_AUTH_TOKEN", "testtoken123")