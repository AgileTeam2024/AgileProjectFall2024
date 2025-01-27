from unittest import mock
from unittest.mock import patch

import flask
import flask_jwt_extended
from absl.testing import absltest

import backend.managers.admin
import backend.models.report
import backend.models.user
import backend.routes.admin
import backend.initializers.settings
import backend.initializers.test_util


class UserManagerTest(absltest.TestCase):
    def setUp(self) -> None:
        super().setUp()
        self.flask_app = flask.Flask(__name__)
        self.flask_app.config['JWT_SECRET_KEY'] = 'app_secret_key'
        self.flask_app.register_blueprint(backend.routes.admin.admin_bp, url_prefix='/api/admin')
        self.jwt_manager = flask_jwt_extended.JWTManager(self.flask_app)
        self.client = self.flask_app.test_client()
        self.flask_app.app_context().push()
        self.mock_manager = mock.patch("backend.managers.admin.AdminManager").start()
        self.admin_token = flask_jwt_extended.create_access_token(identity="admin")
        self.admin = backend.models.user.User(username="admin", password="admin", email="admin@gmail.com",
                                              is_admin=True, is_verified=True)
        self.mock_user_query = mock.patch("backend.models.user.User.query").start()

    def tearDown(self) -> None:
        self.mock_manager.stop()
        self.mock_user_query.stop()
        super().tearDown()

    def test_ban_user(self):
        self.mock_user_query.filter_by.return_value.first.return_value = self.admin
        response = self.client.post(
            "/api/admin/ban_user",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"username": "username"}
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_unban_user_no_data_provided(self):
        self.mock_user_query.filter_by.return_value.first.return_value = self.admin
        response = self.client.post(
            "/api/admin/ban_user",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

    def test_unban_user(self):
        self.mock_user_query.filter_by.return_value.first.return_value = self.admin
        response = self.client.post(
            "/api/admin/ban_user",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"username": "username"}
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_unban_user_no_data_provided(self):
        self.mock_user_query.filter_by.return_value.first.return_value = self.admin
        response = self.client.post(
            "/api/admin/ban_user",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

    def test_ban_product(self):
        self.mock_user_query.filter_by.return_value.first.return_value = self.admin
        response = self.client.post(
            "/api/admin/ban_product",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"product_id": "1"}
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_ban_product_no_data_provided(self):
        self.mock_user_query.filter_by.return_value.first.return_value = self.admin
        response = self.client.post(
            "/api/admin/ban_product",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

    def test_unban_product(self):
        self.mock_user_query.filter_by.return_value.first.return_value = self.admin
        response = self.client.post(
            "/api/admin/unban_product",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"product_id": "1"}
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_unban_product_no_data_provided(self):
        self.mock_user_query.filter_by.return_value.first.return_value = self.admin
        response = self.client.post(
            "/api/admin/unban_product",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)


if __name__ == "__main__":
    backend.initializers.test_util.pass_flags_as_parsed()
    absltest.main()
