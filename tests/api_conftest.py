import os
import pytest
import requests

@pytest.fixture(scope="session", autouse=True)
def base_url():
    """
    Base URL for the API under test. Can be overridden by setting BASE_URL env var.
    """
    return os.getenv("BASE_URL", "https://api.qa.example.com")


@pytest.fixture(scope="session", autouse=True)
def auth_token():
    """
    Auth token for Bearer authentication. Can be overridden with AUTH_TOKEN env var.
    """
    return os.getenv("AUTH_TOKEN", "testtoken123")


@pytest.fixture(scope="session")
def session():
    s = requests.Session()
    yield s
    s.close()


@pytest.fixture
def headers(auth_token):
    return {
        "Authorization": f"Bearer {auth_token}",
        "Accept": "application/json",
        "Content-Type": "application/json",
    }
