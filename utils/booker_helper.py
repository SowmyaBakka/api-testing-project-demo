import requests

class BookHelper:
    BASE_URL = "https://restful-booker.herokuapp.com"
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({"Accept":"application/json"})
        self.token = None
    def authenticate(self,username="admin",password = "password123"):
        payload = {"username":username,"password":password}
        response = self.session.post(f"{self.BASE_URL}/auth",json=payload)
        if response.status_code ==200:
            self.token = response.json().get("token")
            self.session.headers.update({"Cookie": f"token={self.token}"})
            #self.session.headers.update({"Authorization": f"Basic YWRtaW46cGFzc3dvcmQxMjM="})
            return self.token
    def get_bookings(self,params=None):
        """ Get all bookings"""
        return self.session.get(f"{self.BASE_URL}/booking",params=params)
    def get_booking(self,booking_id):
        """Get a single booking id"""
        return self.session.get(f"{self.BASE_URL}/booking/{booking_id}",json="payload")
    def create_booking(self,payload):
        """Create a new booking"""
        return self.session.post(f"{self.BASE_URL}/booking",json=payload)
    def update_booking(self,booking_id,payload):
        """Update an existing booking with updated payload and idenitufying it with booking id"""
        return self.session.put(f"{self.BASE_URL}/booking/{booking_id}",json=payload)
    def partial_update_booking(self,booking_id,payload):
        """Update the booking partially with updated payload and indentifying it with booking_id"""
        return self.session.patch(f"{self.BASE_URL}/booking/{booking_id}",json=payload)
    def delete_booking(self, booking_id):
        """DELETE /booking/{id}"""
        return self.session.delete(f"{self.BASE_URL}/booking/{booking_id}")
    def ping(self):
        """GET /ping - health check"""
        return self.session.get(f"{self.BASE_URL}/ping")