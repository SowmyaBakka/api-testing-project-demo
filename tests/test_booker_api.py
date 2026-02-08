import pytest

class TestBookerBase:
    """Base class: Reusable assertions (Inheritance OOP)"""
    def assert_success(self, response, expected_status=200):
        assert response.status_code == expected_status, f"Expected {expected_status}, got {response.status_code} - {response.text}"

    def assert_booking_structure(self, booking):
        assert "firstname" in booking
        assert "bookingdates" in booking
        assert "checkin" in booking["bookingdates"]
class TestBookerCRUD(TestBookerBase):
    def test_get_all_bookings(self,booker_client):
        resp = booker_client.get_bookings()
        self.assert_success(resp)
        data = resp.json()
        assert isinstance(data,list)
        assert len(data)>0
    # def test_create_and_get_new_booking(self,booker_client,sample_booking_payload):
    #     resp = booker_client.