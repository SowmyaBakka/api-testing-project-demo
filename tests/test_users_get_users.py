import pytest


def _get_users(base_url, headers, session):
    url = f"{base_url.rstrip('/')}/users"
    return session.get(url, headers=headers)


def test_validate_response(base_url, headers, session):
    resp = _get_users(base_url, headers, session)
    assert resp is not None
    assert resp.status_code == 200, f"Expected 200 OK, got {resp.status_code}. Body: {resp.text}"


def test_validate_response_body(base_url, headers, session):
    resp = _get_users(base_url, headers, session)
    assert resp.content, "Response body is empty"
    try:
        data = resp.json()
    except ValueError:
        pytest.fail("Response body is not valid JSON")

    # If the API returns a list of users
    if isinstance(data, list):
        # It's acceptable for list to be empty; if not empty, check user object fields
        if len(data) > 0:
            first = data[0]
            assert isinstance(first, dict), "User item is not an object"
            assert "id" in first, "User object missing 'id' field"
    elif isinstance(data, dict):
        # If it returns an envelope, try common keys
        # Ensure it's not empty
        assert len(data) > 0, "Response JSON object is empty"
        # try to find list of users
        users = None
        for k in ("users","data","items","results"):
            if k in data and isinstance(data[k], list):
                users = data[k]
                break
        if users is not None:
            if len(users) > 0:
                assert "id" in users[0], "User object in list missing 'id' field"
        else:
            # if no list found, check that at least one of expected user fields exists at top-level
            for field in ("id","username","email"):
                if field in data:
                    break
            else:
                pytest.fail("Response JSON does not contain expected user fields ('id', 'username', 'email')")
