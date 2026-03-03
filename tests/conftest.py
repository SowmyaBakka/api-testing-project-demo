import os
import pytest

# Fixture that provides the base URL for the API
@pytest.fixture(scope="session")
def base_url():
    """Return the base URL for tests. Can be overridden via BASE_URL env var."""
    return os.getenv("BASE_URL", "https://api.dev.example.com")


# Fixture that provides an auth token for Bearer auth
@pytest.fixture(scope="session")
def auth_token():
    """Return an authorization token. Can be overridden via AUTH_TOKEN env var."""
    # Note: this fixture returns the raw token string (without the 'Bearer ' prefix)
    return os.getenv("AUTH_TOKEN", "test-token")


# Autouse fixture 1: ensure environment variables are set to defaults if missing
@pytest.fixture(autouse=True)
def ensure_default_env(monkeypatch):
    """Automatically ensure BASE_URL and AUTH_TOKEN are present in the environment for tests."""
    if not os.getenv("BASE_URL"):
        monkeypatch.setenv("BASE_URL", "https://api.dev.example.com")
    if not os.getenv("AUTH_TOKEN"):
        monkeypatch.setenv("AUTH_TOKEN", "test-token")
    yield


# Autouse fixture 2: lightweight global setup (no-op for now, reserved for global test setup)
@pytest.fixture(autouse=True)
def global_test_setup():
    """Run simple global setup before every test (autouse). Currently a no-op but kept for extensibility."""
    # Could initialize logging, test counters, or other global behaviors here
    yield
