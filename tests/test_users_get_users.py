import requests
import pytest


def _build_headers(auth_token: str) -> dict:
    # auth_token fixture returns raw token, attach 'Bearer '
    token = auth_token
    if not token.lower().startswith("bearer "):
        token = f"Bearer {token}"
    return {"Authorization": token, "Accept": "application/json"}


def test_validate_response(base_url, auth_token):
    """Validate HTTP response code and that body exists for GET /users"""
    url = f"{base_url.rstrip('/')}/users"
    headers = _build_headers(auth_token)

    resp = requests.get(url, headers=headers, params={"limit": 20, "offset": 0})

    # Validate response code
    assert resp is not None, "No response returned from the server"
    assert resp.status_code == 200, f"Expected 200 OK, got {resp.status_code}. Response body: {resp.text}"

    # Validate body presence
    assert resp.content, "Response body is empty"


def test_validate_response_body(base_url, auth_token):
    """Validate response JSON structure for GET /users - check presence of expected fields"""
    url = f"{base_url.rstrip('/')}/users"
    headers = _build_headers(auth_token)

    resp = requests.get(url, headers=headers, params={"limit": 20, "offset": 0})

    # Basic checks
    assert resp.status_code == 200, f"Expected 200 OK, got {resp.status_code}."

    content_type = resp.headers.get("Content-Type", "")
    assert "json" in content_type.lower(), f"Expected JSON response, got Content-Type: {content_type}"

    # Parse JSON
    try:
        data = resp.json()
    except ValueError:
        pytest.fail("Response body is not valid JSON")

    assert data is not None, "Response JSON is empty"

    # The API spec does not include concrete response schema for /users.
    # Validate generically: response should be a list or a dict containing user records.
    expected_user_fields = {"id", "email", "name", "username"}

    if isinstance(data, list):
        # If list, ensure at least the list exists (may be empty in some environments)
        assert isinstance(data, list), "Expected JSON array for users list"
        if len(data) > 0:
            first = data[0]
            assert isinstance(first, dict), "User item is not an object"
            assert any(field in first for field in expected_user_fields), (
                f"None of expected user fields {expected_user_fields} found in item: {first}"
            )
    elif isinstance(data, dict):
        # If paginated object, try common container keys
        possible_containers = ["items", "users", "data", "results"]
        found = False
        for key in possible_containers:
            if key in data and isinstance(data[key], list) and len(data[key]) > 0:
                first = data[key][0]
                assert isinstance(first, dict), "User item inside container is not an object"
                assert any(field in first for field in expected_user_fields), (
                    f"None of expected user fields {expected_user_fields} found in item: {first}"
                )
                found = True
                break
        if not found:
            # If no container, check if the dict itself looks like a user
            assert any(field in data for field in expected_user_fields), (
                f"Response dict does not contain any expected user fields: {expected_user_fields}"
            )
    else:
        pytest.fail(f"Unexpected JSON response type: {type(data)}")
