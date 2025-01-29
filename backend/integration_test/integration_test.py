import requests

from absl.testing import absltest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

import backend.models.user
import backend.models.report
import backend.initializers.settings


class IntegrationTest(absltest.TestCase):
    REGISTER_API = "http://flask_app_integration:5000/api/user/register"
    LOGIN_API = "http://flask_app_integration:5000/api/user/login"
    EDIT_PROFILE_API = "http://flask_app_integration:5000/api/user/edit_profile"
    GET_PROFILE_API = "http://flask_app_integration:5000/api/user/get_profile"
    REPORT_USER_API = "http://flask_app_integration:5000/api/user/report_user"
    REFRESH_TOKEN_API = "http://flask_app_integration:5000/api/user/refresh"
    DELETE_USER_API = "http://flask_app_integration:5000/api/user/delete"
    DATABASE_URI = (
        f"postgresql://"
        f"postgres:postgres"
        f"@flask_db_integration:5432"
        f"/test"
    )

    @classmethod
    def setUpClass(cls):
        # Set up database connection for testing.
        cls.engine = create_engine(cls.DATABASE_URI)
        cls.Session = sessionmaker(bind=cls.engine)

    def test_integration(self) -> None:
        # Register.
        response = requests.post(
            self.REGISTER_API, json={'username': 'username', 'password': 'password', 'email': 'user@gmail.com'}
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.CREATED.value)
        session = self.Session()
        user = session.query(backend.models.user.User).filter_by(username='username').first()
        # Assert that the user exists in the database.
        self.assertIsNotNone(user)
        self.assertEqual(user.username, 'username')

        # Verify the Email.
        session = self.Session()
        user = session.query(backend.models.user.User).filter_by(username='username').first()
        user.is_verified = True
        session.commit()

        # Login.
        response = requests.post(
            self.LOGIN_API, json={'username': 'username', 'password': 'password'}
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)
        access_token = response.json().get('access_token')
        refresh_token = response.json().get('refresh_token')
        self.assertIsNotNone(access_token)

        # Edit profile.
        response = requests.put(
            self.EDIT_PROFILE_API,
            data={'first_name': 'farhad', 'last_name': 'esmaeilzadeh'},
            headers={'Authorization': f'Bearer {access_token}'}
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

        # Get profile.
        response = requests.get(
            self.GET_PROFILE_API,
            headers={'Authorization': f'Bearer {access_token}'}
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(response.json().get('profile').get('first_name'), 'farhad')
        self.assertEqual(response.json().get('profile').get('last_name'), 'esmaeilzadeh')

        # Create a user to report.
        user_report = backend.models.user.User(username="user_report", password="password", email="user2@gmail.com")
        session = self.Session()
        session.add(user_report)
        session.commit()

        # Report user.
        response = requests.post(
            self.REPORT_USER_API,
            data={'reported_username': 'user_report', 'description': 'description'},
            headers={'Authorization': f'Bearer {access_token}'}
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)
        report = session.query(backend.models.report.UserReport).filter_by(reported_user='user_report').first()
        self.assertIsNotNone(report)

        # Refresh token.
        response = requests.get(
            self.REFRESH_TOKEN_API,
            headers={'Authorization': f'Bearer {refresh_token}'}
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)
        access_token = response.json().get('access_token')

        # Delete user.
        response = requests.delete(
            self.DELETE_USER_API,
            headers={'Authorization': f'Bearer {access_token}'}
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.NO_CONTENT.value)
        session = self.Session()
        user = session.query(backend.models.user.User).filter_by(username='username').first()
        self.assertIsNone(user)


if __name__ == "__main__":
    absltest.main()
