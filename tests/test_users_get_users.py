import requests
import pytest


def test_validate_response(base_url, headers):
    """Validate HTTP response code for GET /users"""
    params = {"limit": 20, "offset": 0}
    resp = requests.get(f"{base_url}/users", headers=headers, params=params, timeout=10)
    assert resp.status_code == 200, f"Unexpected status code: {resp.status_code}, body: {resp.text}"


def test_validate_response_body(base_url, headers):
    """Validate response body exists and basic required fields are present for GET /users"""
    params = {"limit": 20, "offset": 0}
    resp = requests.get(f"{base_url}/users", headers=headers, params=params, timeout=10)
    assert resp.status_code == 200, f"Unexpected status code: {resp.status_code}, body: {resp.text}"

    # Ensure body present
    assert resp.text and resp.text.strip() != "", "Response body is empty"

    # Ensure JSON response
    content_type = resp.headers.get("Content-Type", "")
    assert "application/json" in content_type.lower(), f"Expected JSON response but got Content-Type: {content_type}"

    data = resp.json()
    assert data is not None

    # Accept either a list of users or an envelope object containing a users/data/results list
    if isinstance(data, list):
        # If list non-empty, check basic user fields
        if len(data) > 0:
            first = data[0]
            assert isinstance(first, dict), "User entry is not an object"
            assert "id" in first, "Field 'id' missing in user object"
            assert ("email" in first) or ("username" in first) or ("name" in first), "One of 'email'/'username'/'name' should be present in user object"
    elif isinstance(data, dict):
        users = data.get("users") or data.get("data") or data.get("results")
        if isinstance(users, list) and len(users) > 0:
            first = users[0]
            assert "id" in first
        else:
            # Might be a single user object
            assert "id" in data
