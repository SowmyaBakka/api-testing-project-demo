import pytest
from utils.booker_helper import BookHelper
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