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
        self.product_manager = backend.managers.product.ProductManager(flask_app=self.flask_app)
        # Mock database session.
        self.mock_db_session = mock.patch("backend.initializers.database.DB.session").start()
        # Mock query on user model.
        self.mock_user_query = mock.patch("backend.models.user.User.query").start()
        self.mock_product_query = mock.patch("backend.models.product.Product.query").start()
        self.mock_product_picture_query = mock.patch("backend.models.product.Picture.query").start()
        self.mock_user_picture_query = mock.patch("backend.models.user.ProfilePicture.query").start()
        self.mock_product_report_query = mock.patch("backend.models.report.ProductReport.query").start()
        self.mock_user_report_query = mock.patch("backend.models.report.UserReport.query").start()

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

    def test_successful_get_profile(self):
        """Test successful get_profile_by_username."""
        self.mock_user_query.filter_by.return_value.first.return_value = backend.models.user.User(
            username="user1",
            password="password123"
        )
        response, status_code = self.user_manager.get_profile("user1")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(response.json, {'profile': {'email': None, 'first_name': None, 'is_admin': None, 'is_banned': None, 'is_verified': None, 'last_name': None, 'phone_number': None, 'profile_picture': None, 'username': 'user1'}})

    def test_get_profile_does_not_exist(self):
        """Test non-existent get_profile_by_username."""
        self.mock_user_query.filter_by.return_value.first.return_value = None
        response, status_code = self.user_manager.get_profile("user1")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.NOT_FOUND.value)
        self.assertEqual(response.json, {'message': 'User does not exist.'})


    def test_delete_account_deletes_other_items_too(self):
        """Test that deleting a user account removes all associated items."""
    def test_delete_account_deletes_other_items_too(self):
        user1 = backend.models.user.User(username='user1', password='pass', email='user1@gmail.com', is_verified=True)
        user2 = backend.models.user.User(username='user2', password='pass', email='user2@gmail.com', is_verified=True, profile_picture='picture.jpg')
        user3 = backend.models.user.User(username='user3', password='pass', email='user3@gmail.com', is_verified=True)
        product = backend.models.product.Product(id=1, user_username=user2.username, name='product', price=10, status='for sale', category='Others')
        product_picture = backend.models.product.Picture(product_id=product.id, filename='picture.jpg')
        user_picture = backend.models.user.ProfilePicture(user_username=user2.username, filename='picture.jpg')
        product_report = backend.models.report.ProductReport(reported_product=product.id, reporter_username=user2.username, description='report')
        user_report1 = backend.models.report.UserReport(reported_user=user1.username, reporter_username=user2.username, description='report')
        user_report2 = backend.models.report.UserReport(reported_user=user2.username, reporter_username=user3.username, description='report')

        # self.mock_product_query.filter_by(id=product.id).return_value.first.return_value = product
        # self.mock_product_query.filter_by(user_username=product.user_username).return_value.all.return_value = [product]
        self.mock_product_query.filter_by.return_value.all.return_value = [product]
        self.mock_product_picture_query.filter_by(product_id=product.id).return_value.all.return_value = [product_picture]
        self.mock_user_picture_query.filter_by(user_username=user2.username).return_value.first.return_value = user_picture
        self.mock_product_report_query.filter_by(reporter_username=user2.username).return_value.all.return_value = [product_report]
        self.mock_user_report_query.filter_by(reporter_username=user2.username).return_value.all.return_value = [user_report1]
        self.mock_user_report_query.filter_by(reported_user=user2.username).return_value.all.return_value = [user_report2]

        with mock.patch("flask_jwt_extended.get_jwt_identity", return_value=user2.username):
            response, status_code = self.user_manager.delete_account(user2.username)

        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.NO_CONTENT.value)

        self.mock_product_picture_query.filter_by(product_id=product.id).delete.assert_called_once()
        self.mock_user_picture_query.filter_by(user_username=user2.username).delete.assert_called_once()
        self.mock_product_report_query.filter_by(reporter_username=user2.username).delete.assert_called_once()
        self.mock_product_query.filter_by(id=product.id).delete.assert_called_once()
        self.mock_user_report_query.filter_by(reporter_username=user2.username).delete.assert_called()
        self.mock_user_report_query.filter_by(reported_user=user2.username).delete.assert_called()
        self.mock_user_query.filter_by(username=user2.username).delete.assert_called_once()


if __name__ == "__main__":
    backend.initializers.test_util.pass_flags_as_parsed()
    absltest.main()
