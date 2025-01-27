import itsdangerous
from unittest import mock
from unittest.mock import MagicMock

import flask
import flask_mail
import flask_jwt_extended
from absl.testing import absltest

import backend.initializers.settings
import backend.initializers.test_util
import backend.managers.user
import backend.models.user


class UserManagerTest(absltest.TestCase):
    def setUp(self) -> None:
        super().setUp()
        self.flask_app = flask.Flask(__name__)
        # Do not send email in test environment.
        self.flask_app.config['MAIL_SUPPRESS_SEND'] = True
        self.flask_app.config['SERVER_NAME'] = 'pre-loved.ir'
        self.flask_app.config['MAIL_DEFAULT_SENDER'] = "email@example.com"
        self.flask_app.config['MAIL_USERNAME'] = "email@example.com"
        self.flask_app.config['JWT_SECRET_KEY'] = 'app_secret_key'
        self.jwt_manager = flask_jwt_extended.JWTManager(self.flask_app)
        self.flask_app.app_context().push()
        self.user_manager = (backend.managers.user.UserManager.instance or
                             backend.managers.user.UserManager(flask_app=self.flask_app))
        # Mock database session.
        self.mock_db_session = mock.patch("backend.initializers.database.DB.session").start()
        # Mock query on user model.
        self.mock_user_query = mock.patch("backend.models.user.User.query").start()

    def tearDown(self) -> None:
        self.mock_db_session.stop()
        self.mock_user_query.stop()
        super().tearDown()

    def test_register_username_exist(self) -> None:
        """Test that registration fails when the username already exists."""
        self.mock_user_query.filter_by.return_value.first.return_value = backend.models.user.User(
            username="existing_user"
        )
        response, status_code = self.user_manager.register("existing_user", "password123")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)
        self.assertEqual(response.json, {'message': 'Username already exists'})

    def test_register_email_exist(self) -> None:
        """Test that registration fails when the email already exists."""

        def mock_filter_by(**kwargs):
            if 'username' in kwargs and kwargs['username'] == "nonexisting_user":
                return MagicMock(first=lambda: None)  # No user with this username
            if 'email' in kwargs and kwargs['email'] == "existing_email@email.com":
                return MagicMock(first=lambda: backend.models.user.User(
                    username="existing_user",
                    email="existing_email@email.com"
                ))  # Simulate an existing email

        self.mock_user_query.filter_by.side_effect = mock_filter_by

        response, status_code = self.user_manager.register("nonexisting_user", "password123",
                                                           "existing_email@email.com")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)
        self.assertEqual(response.json, {'message': 'Email already exists'})

    def test_register_successful(self) -> None:
        """Test that a new user can register successfully with a unique username."""
        self.mock_user_query.filter_by.return_value.first.return_value = None
        response, status_code = self.user_manager.register("new_user", "password123",
                                                           "nonexisting_user@email.com")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.CREATED.value)
        self.assertEqual(response.json, {"message": "User registered successfully."})

    def test_login_username_does_not_exist(self) -> None:
        """Test that login fails when the username does not exist."""
        self.mock_user_query.filter_by.return_value.first.return_value = None
        response, status_code = self.user_manager.login("user", "password123")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)
        self.assertEqual(response.json, {'message': 'Username and password do not match.'})

    def test_login_incorrect_password(self) -> None:
        """Test that login fails when the password is incorrect."""
        self.mock_user_query.filter_by.return_value.first.return_value = backend.models.user.User(
            username="user",
            password="password123",
            is_verified=True
        )
        response, status_code = self.user_manager.login("user", "invalid_password")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)
        self.assertEqual(response.json, {'message': 'Username and password do not match.'})

    def test_successful_login(self) -> None:
        """Test that login succeeds."""
        self.mock_user_query.filter_by.return_value.first.return_value = backend.models.user.User(
            username="user",
            password="password123",
            is_verified=True
        )
        response, status_code = self.user_manager.login("user", "password123")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        # Check if the response contains token.
        data = response.get_json()
        self.assertIn('access_token', data)
        self.assertIn('refresh_token', data)
        # Verify that the token is not empty.
        access_token = data['access_token']
        self.assertTrue(access_token)
        # Verify that the token is not empty.
        refresh_token = data['refresh_token']
        self.assertTrue(refresh_token)

    def test_successful_report(self):
        """Test that reporting user is successful."""
        self.mock_user_query.filter_by.return_value.first.return_value = backend.models.user.User(
            username="user",
            password="password123"
        )
        response, status_code = self.user_manager.report_user("user1", "user", "dummy")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(response.json, {'message': 'User is reported successfully.'})

    def test_user_report_user_does_not_exist(self):
        """Test invalidating reporting non-existent user."""
        self.mock_user_query.filter_by.return_value.first.return_value = None
        response, status_code = self.user_manager.report_user("user1", "user", "dummy")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)
        self.assertEqual(response.json, {'message': 'The reported user does not exist.'})


if __name__ == "__main__":
    backend.initializers.test_util.pass_flags_as_parsed()
    absltest.main()
