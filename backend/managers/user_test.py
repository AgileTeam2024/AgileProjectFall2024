from unittest import mock
from unittest.mock import MagicMock

import flask
import flask_jwt_extended
import werkzeug.datastructures.headers
from absl import flags
from absl.testing import absltest

import backend.initializers.settings
import backend.managers.user
import backend.models.user


class UserManagerTest(absltest.TestCase):
    def setUp(self) -> None:
        super().setUp()
        self.flask_app = flask.Flask(__name__)
        self.flask_app.config['JWT_SECRET_KEY'] = 'app_secret_key'
        self.jwt_manager = flask_jwt_extended.JWTManager(self.flask_app)
        self.flask_app.app_context().push()
        self.user_manager = backend.managers.user.UserManager(flask_app=self.flask_app)
        # Mock database session.
        self.mock_db_session = mock.patch("backend.initializers.database.DB.session").start()
        # Mock query on user model.
        self.mock_user_query = mock.patch("backend.models.user.User.query").start()
        # Mock query on cookie model
        self.mock_cookie_query = mock.patch("backend.models.cookie.Cookie.query").start()

    def tearDown(self) -> None:
        self.mock_db_session.stop()
        self.mock_user_query.stop()
        self.mock_cookie_query.stop()
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

        response, status_code = self.user_manager.register("nonexisting_user", "password123", "existing_email@email.com")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)
        self.assertEqual(response.json, {'message': 'Email already exists'})

    def test_register_email_incorrect_format(self) -> None:
        """Test that registration fails when the format is wrong."""
        for email in ["abc", "abc@", "abc@email", "abc@email.", "@", "@email", "@email.com", "email.com", ".com", "com"]:
            with self.subTest(msg=f"Checking for invalid email {email}", email=email):
                self.mock_user_query.filter_by.return_value.first.return_value = None
                response, status_code = self.user_manager.register("nonexisting_user", "password123", email)
                self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)
                self.assertEqual(response.json, {'message': 'Email must be the correct format.'})

    def test_register_successful(self) -> None:
        """Test that a new user can register successfully with a unique username."""
        self.mock_user_query.filter_by.return_value.first.return_value = None
        response, status_code = self.user_manager.register("new_user", "password123")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.CREATED.value)
        self.assertEqual(response.json, {"message": "User registered successfully."})

    def test_register_email_successful(self) -> None:
        """Test that registration is succcessful if everything is good."""
        self.mock_user_query.filter_by.return_value.first.return_value = None
        response, status_code = self.user_manager.register("nonexisting_user", "password123", "nonexisting_user@email.com")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.CREATED.value)
        self.assertEqual(response.json, {'message': 'User registered successfully.'})

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
            password="password123"
        )
        response, status_code = self.user_manager.login("user", "invalid_password")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)
        self.assertEqual(response.json, {'message': 'Username and password do not match.'})

    def test_successful_login(self) -> None:
        """Test that login succeeds."""
        self.mock_user_query.filter_by.return_value.first.return_value = backend.models.user.User(
            username="user",
            password="password123"
        )
        response, status_code = self.user_manager.login("user", "password123")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        # Check if the response contains the correct message.
        self.assertEqual(response.json, {'message': 'Login successful!'})
        # Verify that the token cookie is in headers.
        headers = dict(response.headers.items())
        self.assertIn('Set-Cookie', headers)
        self.assertNotEmpty(headers['Set-Cookie'].split(';')[0])
        self.mock_db_session.add.assert_called()
        # Verify that a new Cookie was added to the database.
        args, _ = self.mock_db_session.add.call_args
        added_cookie = args[0]
        self.assertIsInstance(added_cookie, backend.models.cookie.Cookie)
        self.assertEqual(added_cookie.username, "user")
        self.assertNotEmpty(added_cookie.cookie)

    def test_check_cookie_non_existence(self) -> None:
        """Test that checks cookie fails if cookie doesn't exist in database"""
        with self.flask_app.test_request_context(headers={"Cookie": "access_token_cookie=fake_access_token"}):
            self.mock_cookie_query.filter_by.return_value.first.return_value = None
            response, status_code = self.user_manager.check_cookie()
            self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.UNAUTHORIZED.value)
            self.assertEqual(response.json, {'msg': 'Token is invalid.'})


if __name__ == "__main__":
    # Set required flags to suppress unit-test's flag parse error.
    flags.FLAGS.__setattr__(backend.initializers.settings.db_username.name, "db_username")
    flags.FLAGS.__setattr__(backend.initializers.settings.db_password.name, "db_password")
    flags.FLAGS.__setattr__(backend.initializers.settings.db_name.name, "db_name")
    flags.FLAGS.__setattr__(backend.initializers.settings.db_host.name, "db_host")
    flags.FLAGS.__setattr__(backend.initializers.settings.db_port.name, "db_port")
    flags.FLAGS.__setattr__(backend.initializers.settings.app_secret_key.name, "app_secret_key")

    absltest.main()
