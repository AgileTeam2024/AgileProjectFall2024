from unittest import mock

import flask
import flask_jwt_extended
from absl.testing import absltest

import backend.managers.admin
import backend.models.report
import backend.models.user
import backend.routes.user
import backend.initializers.settings
import backend.initializers.test_util


class UserRouteTest(absltest.TestCase):
    def setUp(self) -> None:
        super().setUp()
        self.flask_app = flask.Flask(__name__)
        self.flask_app.config['JWT_SECRET_KEY'] = 'app_secret_key'
        self.flask_app.register_blueprint(backend.routes.user.user_bp, url_prefix='/api/user')
        self.jwt_manager = flask_jwt_extended.JWTManager(self.flask_app)
        self.client = self.flask_app.test_client()
        self.flask_app.app_context().push()
        self.mock_manager = mock.patch("backend.managers.user.UserManager").start()
        self.admin_token = flask_jwt_extended.create_access_token(identity="admin")
        self.refresh_token = flask_jwt_extended.create_refresh_token(identity="admin")
        self.admin = backend.models.user.User(username="admin", password="admin", email="admin@gmail.com",
                                              is_admin=True, is_verified=True)
        self.mock_user_query = mock.patch("backend.models.user.User.query").start()
        self.mock_user_query.filter_by.return_value.first.return_value = self.admin

    def tearDown(self) -> None:
        self.mock_manager.stop()
        self.mock_user_query.stop()
        super().tearDown()

    def test_register(self):
        response = self.client.post(
            "/api/user/register",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            json={},
        )  # No username
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/user/register",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            json={"username": "username"},
        )  # No password
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/user/register",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            json={"username": "username", "password": "password"},
        )  # No email
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/user/register",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            json={"username": "username", "password": "password", "email": "asdd"},
        )  # Invalid email
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/user/register",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            json={"username": "username", "password": "password", "email": "farhad@gmail.com"},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_login(self):
        response = self.client.post(
            "/api/user/login",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            json={},
        )  # No username
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/user/login",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            json={"username": "username"},
        )  # No password
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/user/login",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            json={"username": "username", "password": "password"},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_confirm_email(self):
        response = self.client.get(
            "/api/user/confirm_email/token",
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_resend_email(self):
        response = self.client.post(
            "/api/user/resend_email",
            data={},
        )  # No email
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/user/resend_email",
            data={"email": "asdfa"},
        )  # Invalid email
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/user/resend_email",
            data={"email": "farhad@gmail.com"},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_logout(self):
        response = self.client.delete(
            "/api/user/logout",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_refresh_token(self):
        response = self.client.get(
            "/api/user/refresh",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Access token instead of refresh token
        self.assertEqual(response.status_code, 422)

        response = self.client.get(
            "/api/user/refresh",
            headers={"Authorization": f"Bearer {self.refresh_token}"},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_delete_user(self):
        response = self.client.delete(
            "/api/user/delete",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_get_profile(self):
        response = self.client.get(
            "/api/user/get_profile",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_get_profile_by_username(self):
        response = self.client.get(
            "/api/user/get_profile_by_username/username",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_edit_profile(self):
        response = self.client.put(
            "/api/user/edit_profile",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={'first_name': 'first_name', 'last_name': 'last_name', 'phone_number': 'phone_number',
                  'address': 'address'},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_report_user(self):
        response = self.client.post(
            "/api/user/report_user",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={},
        )  # No reported username
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/user/report_user",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={'reported_username': 'reported_username'},
        )  # No description
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/user/report_user",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={'reported_username': 'reported_username', 'description': 'description'},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)


if __name__ == "__main__":
    backend.initializers.test_util.pass_flags_as_parsed()
    absltest.main()
