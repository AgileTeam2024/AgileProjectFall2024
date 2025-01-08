from unittest import mock

import flask
import flask_jwt_extended
from absl.testing import absltest

import backend.initializers.settings
import backend.initializers.test_util
import backend.managers.product
import backend.models.product


class ProductManagerTest(absltest.TestCase):
    def setUp(self) -> None:
        super().setUp()
        self.flask_app = flask.Flask(__name__)
        self.flask_app.config['JWT_SECRET_KEY'] = 'app_secret_key'
        self.jwt_manager = flask_jwt_extended.JWTManager(self.flask_app)
        self.flask_app.app_context().push()
        self.product_manager = backend.managers.product.ProductManager(flask_app=self.flask_app)
        # Mock database session.
        self.mock_db_session = mock.patch("backend.initializers.database.DB.session").start()
        # Mock query on user model.
        self.mock_product_query = mock.patch("backend.models.product.Product.query").start()
        self.mock_user_query = mock.patch("backend.models.user.User.query").start()
        # Create instances or products for test inputs.
        self.product1 = backend.models.product.Product(id=1, name='Apple iPhone 13', price=999.99, status='reserved')
        self.product2 = backend.models.product.Product(id=2, name='Samsung Galaxy S21', price=799.99, status='reserved')
        self.product3 = backend.models.product.Product(id=3, name='Apple Watch Series 6', price=399.99, status='sold')

        self.user1 = backend.models.user.User(username='seller1', email='seller@email.com')
        self.product4 = backend.models.product.Product(id=4, name='Apple Watch Series 6', price=399.99, status='sold',
                                                       user_username='seller1')
        self.product5 = backend.models.product.Product(id=5, name='Laptop Asus', price=399.99, status='for sale')

    def tearDown(self) -> None:
        self.mock_db_session.stop()
        self.mock_product_query.stop()
        super().tearDown()

    def extract_product_info_for_filters(self, filters) -> (list, list, int):
        """Extract info of products returned as response of 'search_product'."""
        result, status = self.product_manager.search_product(filters=filters)
        result_products = result.json['products']
        return result_products, [product['id'] for product in result_products], status

    def test_search_product_name_filter(self) -> None:
        """Test applying filter on product name."""
        self.mock_product_query.filter.return_value.all.return_value = [self.product1, self.product3]
        filters = {'name': 'Apple'}
        result_products, result_product_ids, status = self.extract_product_info_for_filters(filters)

        self.assertEqual(status, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(len(result_products), 2)
        self.assertIn(1, result_product_ids)
        self.assertIn(3, result_product_ids)
        self.assertNotIn(2, result_product_ids)

    def test_search_product_price_range_filter(self) -> None:
        """Test applying filter on product price."""
        self.mock_product_query.filter.return_value.all.return_value = [self.product2, self.product3]
        filters = {'min_price': 300, 'max_price': 800}
        result_products, result_product_ids, status = self.extract_product_info_for_filters(filters)

        self.assertEqual(status, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(len(result_products), 2)
        self.assertIn(2, result_product_ids)
        self.assertIn(3, result_product_ids)
        self.assertNotIn(1, result_product_ids)

    def test_search_product_status_filter(self) -> None:
        """Test applying filter on product status."""
        self.mock_product_query.filter.return_value.all.return_value = [self.product3]
        filters = {'status': 'sold'}
        result_products, result_product_ids, status = self.extract_product_info_for_filters(filters)

        self.assertEqual(status, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(len(result_products), 1)
        self.assertIn(3, result_product_ids)
        self.assertNotIn(1, result_product_ids)
        self.assertNotIn(2, result_product_ids)

    def test_get_product_by_id(self) -> None:
        """Test Retrieving product by id."""
        self.mock_product_query.get.return_value = self.product1
        result, status = self.product_manager.get_product(1)
        self.assertEqual(status, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(self.product1.to_dict(), result.json['product'])

    def test_get_product_by_id_returns_seller_info_too(self) -> None:
        """Test Retrieving product by id."""
        self.mock_user_query.get.return_value = self.user1
        self.mock_product_query.get.return_value = self.product4
        result, status = self.product_manager.get_product(4)
        self.assertEqual(status, backend.initializers.settings.HTTPStatus.OK.value)
        expected_product = self.product4.to_dict()
        expected_product['seller'] = self.user1.to_dict()
        self.assertEqual(expected_product, result.json['product'])

    def test_successful_report(self):
        """Test that reporting product is successful."""
        self.mock_product_query.filter_by.return_value.first.return_value = self.product1
        response, status_code = self.product_manager.report_product("user",
                                                                    self.product1.id, "dummy")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(response.json, {'message': 'Product is reported successfully.'})

    def test_product_report_product_does_not_exist(self):
        """Test invalidating reporting non-existent product."""
        self.mock_product_query.filter_by.return_value.first.return_value = None
        response, status_code = self.product_manager.report_product("user",
                                                                    self.product1.id, "dummy")
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)
        self.assertEqual(response.json, {'message': 'The reported product does not exist.'})

    def test_edit_product_success(self):
        """Test successful editing of a product."""
        self.mock_product_query.filter_by.return_value.first.return_value = self.product5
        self.mock_user_query.get.return_value = self.user1
        product_data = {
            'name': 'Laptop Lenovo',
            'price': 499.99,
            'description': 'Updated description',
            'status': 'for sale',
            'category': 'Digital & Electronics',
        }
        response, status_code = self.product_manager.edit_product(self.user1.username, self.product1.id, product_data)
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(response.json, {'message': 'Product is edited successfully.'})


if __name__ == "__main__":
    backend.initializers.test_util.pass_flags_as_parsed()
    absltest.main()
