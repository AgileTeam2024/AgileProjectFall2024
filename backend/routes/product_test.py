from unittest import mock

import flask
import flask_jwt_extended
from absl.testing import absltest

import backend.managers.admin
import backend.models.report
import backend.models.user
import backend.routes.product
import backend.initializers.settings
import backend.initializers.test_util


class ProductRouteTest(absltest.TestCase):
    def setUp(self) -> None:
        super().setUp()
        self.flask_app = flask.Flask(__name__)
        self.flask_app.config['JWT_SECRET_KEY'] = 'app_secret_key'
        self.flask_app.register_blueprint(backend.routes.product.product_bp, url_prefix='/api/product')
        self.jwt_manager = flask_jwt_extended.JWTManager(self.flask_app)
        self.client = self.flask_app.test_client()
        self.flask_app.app_context().push()
        self.mock_manager = mock.patch("backend.managers.product.ProductManager").start()
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

    def test_create(self):
        response = self.client.post(
            "/api/product/create",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={},
        )  # No name
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/product/create",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"name": "name"},
        )  # No price
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/product/create",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"name": "name", "price": "asdasfd"},
        )  # Price not float
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/product/create",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"name": "name", "price": 1},
        )  # No description
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/product/create",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"name": "name", "price": 1, "description": "description"},
        )  # no status
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/product/create",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"name": "name", "price": 1, "description": "description"},
        )  # no status
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/product/create",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"name": "name", "price": 1, "description": "description", "status": "a"},
        )  # Bad status
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/product/create",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"name": "name", "price": 1, "description": "description", "status": "Automobile"},
        )  # No category
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/product/create",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"name": "name", "price": 1, "description": "description", "status": "Automobile", "category": "a"},
        )  # Bad category
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/product/create",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"name": "name", "price": 1, "description": "description", "status": "sold",
                  "category": "Automobile"},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_search(self):
        response = self.client.get(
            "/api/product/search?name=name&status=asdsa",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Bad status
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.get(
            "/api/product/search?category=asdsa",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Bad category
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.get(
            "/api/product/search?min_price=a&max_price=2",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Bad min price
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.get(
            "/api/product/search?min_price=1&max_price=a",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Bad max price
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.get(
            "/api/product/search?min_price=1",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # No price range
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.get(
            "/api/product/search?sort_created_at=a",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Bad sort created at
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.get(
            "/api/product/search?sort_price=a",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Bad sort price
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.get(
            "/api/product/search",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_get_product_by_id(self):
        response = self.client.get(
            "/api/product/get_product_by_id",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # No product id
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.get(
            "/api/product/get_product_by_id?product_id=a",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Bad product id
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.get(
            "/api/product/get_product_by_id?product_id=1",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_delete_product(self):
        response = self.client.delete(
            "/api/product/delete",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # No product id
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.delete(
            "/api/product/delete?product_id=a",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Bad product id
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.delete(
            "/api/product/delete?product_id=1",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_edit_product(self):
        response = self.client.put(
            "/api/product/edit_product",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data=[]
        )  # No product ID
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.put(
            "/api/product/edit_product",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"product_id": 1, "name": "name", "price": "a"}
        )  # Bad price
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.put(
            "/api/product/edit_product?product_id=1",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"name": "name", "price": 1, "city_name": "city", "description": "description",
                  "status": "sold", "category": "Automobile"}
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_report_product(self):
        response = self.client.post(
            "/api/product/report_product",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={}
        )  # No reported product
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/product/report_product",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"reported_product": "a"}
        )  # Bad reported product
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/product/report_product",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"reported_product": 1}
        )  # No description
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)

        response = self.client.post(
            "/api/product/report_product",
            headers={"Authorization": f"Bearer {self.admin_token}"},
            data={"reported_product": 1, "description": "description"}
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)

    def test_get_products(self):
        response = self.client.get(
            "/api/product/product_list",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )  # Success
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.OK.value)


if __name__ == "__main__":
    backend.initializers.test_util.pass_flags_as_parsed()
    absltest.main()
