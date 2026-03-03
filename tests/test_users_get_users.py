import requests
import pytest


def test_validate_response(base_url, auth_token):
    """Validate status code for GET /users"""
    headers = {"Authorization": f"Bearer {auth_token}"}
    resp = requests.get(f"{base_url}/users", headers=headers)

    assert resp is not None, "No response received"
    # Basic validation of expected HTTP status code
    assert resp.status_code == 200, f"Unexpected status code: {resp.status_code} - Body: {resp.text}"


def test_validate_response_body(base_url, auth_token):
    """Validate response body presence and required fields for GET /users"""
    headers = {"Authorization": f"Bearer {auth_token}"}
    resp = requests.get(f"{base_url}/users", headers=headers)

    assert resp.content, "Response body is empty"

    try:
        data = resp.json()
    except ValueError:
        pytest.fail("Response is not valid JSON")

    # Try to locate a list of user objects in the response
    users = None
    if isinstance(data, list):
        users = data
    elif isinstance(data, dict):
        for key in ("users", "data", "items"):
            if key in data and isinstance(data[key], list):
                users = data[key]
                break
        # single user object
        if users is None and all(k in data for k in ("id", "email")):
            users = [data]

    assert users is not None, "Could not find users list or user object in response"

    # Required fields for a user object (best-effort based on API semantics)
    required = ("id", "email")
    for u in users:
        for r in required:
            assert r in u, f"Required field '{r}' missing in user object: {u}"
