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
        # Create instances or products for test inputs.
        self.product1 = backend.models.product.Product(id=1, name='Apple iPhone 13', price=999.99, status='reserved')
        self.product2 = backend.models.product.Product(id=2, name='Samsung Galaxy S21', price=799.99, status='reserved')
        self.product3 = backend.models.product.Product(id=3, name='Apple Watch Series 6', price=399.99, status='sold')

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


if __name__ == "__main__":
    backend.initializers.test_util.pass_flags_as_parsed()
    absltest.main()
