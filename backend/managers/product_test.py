from unittest import mock

import flask
import flask_jwt_extended
from absl.testing import absltest

import backend.initializers.settings
import backend.initializers.test_util
import backend.managers.product
import backend.models.product
import backend.models.user


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
        self.mock_product_picture_query = mock.patch("backend.models.product.Picture.query").start()
        self.mock_user_picture_query = mock.patch("backend.models.user.ProfilePicture.query").start()
        self.mock_product_report_query = mock.patch("backend.models.report.ProductReport.query").start()
        # Create instances of products and users for test inputs.
        self.user1 = backend.models.user.User(username='seller1', email='seller@email.com')
        self.user2 = backend.models.user.User(username='seller2', email='seller2@email.com')
        self.product1 = backend.models.product.Product(id=1, name='Apple iPhone 13', price=999.99, status='reserved',
                                                       user_username='seller1')
        self.product2 = backend.models.product.Product(id=2, name='Samsung Galaxy S21', price=799.99, status='reserved',
                                                       user_username='seller1')
        self.product3 = backend.models.product.Product(id=3, name='Apple Watch Series 6', price=399.99, status='sold',
                                                       user_username='seller1')
        self.product4 = backend.models.product.Product(id=4, name='Apple Watch Series 6', price=399.99, status='sold',
                                                       user_username='seller1')
        self.product5 = backend.models.product.Product(id=5, name='Laptop Asus', price=399.99, status='for sale',
                                                       user_username='seller1')
        self.product6 = backend.models.product.Product(id=6, name='Red Phone', price=399.99, status='for sale',
                                                       user_username='seller2')
        self.product7 = backend.models.product.Product(id=7, name='Blue Phone', price=400.99, status='for sale',
                                                       user_username='seller2')
        self.product8 = backend.models.product.Product(id=8, name='Pink Phone', price=367.99, status='sold',
                                                       user_username='seller2')

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
        self.mock_user_query.get.return_value = self.user1
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
        self.mock_user_query.get.return_value = self.user1
        filters = {'min_price': 300, 'max_price': 800}
        result_products, result_product_ids, status = self.extract_product_info_for_filters(filters)

        self.assertEqual(status, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(len(result_products), 2)
        self.assertIn(2, result_product_ids)
        self.assertIn(3, result_product_ids)
        self.assertNotIn(1, result_product_ids)

    def test_search_product_sort_price_asc(self) -> None:
        """Test applying filter on sorting price asc."""
        self.mock_product_query.filter.return_value.all.return_value = [self.product2, self.product3]
        self.mock_product_query.order_by.return_value.all.return_value = [self.product2, self.product3]
        self.mock_user_query.get.return_value = self.user1
        filters = {'sort_price': 'asc'}
        result_products, result_product_ids, status = self.extract_product_info_for_filters(filters)

        self.assertEqual(status, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(len(result_products), 2)
        self.assertEqual(result_products[0]['id'], 2)
        self.assertEqual(result_products[1]['id'], 3)

    def test_search_product_sort_price_dsc(self) -> None:
        """Test applying filter on sorting price dsc."""
        self.mock_product_query.filter.return_value.all.return_value = [self.product3, self.product2]
        self.mock_product_query.order_by.return_value.all.return_value = [self.product3, self.product2]
        self.mock_user_query.get.return_value = self.user1
        filters = {'sort_price': 'asc'}
        result_products, result_product_ids, status = self.extract_product_info_for_filters(filters)

        self.assertEqual(status, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(len(result_products), 2)
        self.assertEqual(result_products[0]['id'], 3)
        self.assertEqual(result_products[1]['id'], 2)

    def test_search_product_sort_created_time_asc(self) -> None:
        """Test applying filter on created time asc."""
        self.mock_product_query.filter.return_value.all.return_value = [self.product1, self.product2]
        self.mock_product_query.order_by.return_value.all.return_value = [self.product1, self.product2]
        self.mock_user_query.get.return_value = self.user1
        filters = {'sort_created_at': 'asc'}
        result_products, result_product_ids, status = self.extract_product_info_for_filters(filters)

        self.assertEqual(status, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(len(result_products), 2)
        self.assertEqual(result_products[0]['id'], 1)
        self.assertEqual(result_products[1]['id'], 2)

    def test_search_product_sort_created_time_dsc(self) -> None:
        """Test applying filter on created time dsc."""
        self.mock_product_query.filter.return_value.all.return_value = [self.product2, self.product1]
        self.mock_product_query.order_by.return_value.all.return_value = [self.product2, self.product1]
        self.mock_user_query.get.return_value = self.user1
        filters = {'sort_created_at': 'dsc'}
        result_products, result_product_ids, status = self.extract_product_info_for_filters(filters)

        self.assertEqual(status, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(len(result_products), 2)
        self.assertEqual(result_products[0]['id'], 2)
        self.assertEqual(result_products[1]['id'], 1)

    def test_search_product_status_filter(self) -> None:
        """Test applying filter on product status."""
        self.mock_product_query.filter.return_value.all.return_value = [self.product3]
        self.mock_user_query.get.return_value = self.user1
        filters = {'status': ['sold']}
        result_products, result_product_ids, status = self.extract_product_info_for_filters(filters)

        self.assertEqual(status, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(len(result_products), 1)
        self.assertIn(3, result_product_ids)
        self.assertNotIn(1, result_product_ids)
        self.assertNotIn(2, result_product_ids)

    def test_get_product_by_id(self) -> None:
        """Test Retrieving product by id."""
        self.mock_product_query.get.return_value = self.product1
        self.mock_user_query.get.return_value = self.user1
        result, status = self.product_manager.get_product(1)
        self.assertEqual(status, backend.initializers.settings.HTTPStatus.OK.value)
        expected = {
            'category': None, 'city_name': None, 'created_at': None, 'description': None, 'id': 1, 'is_banned': None,
            'name': 'Apple iPhone 13', 'pictures': [], 'price': 999.99,
            'seller': {
                'email': 'seller@email.com', 'first_name': None, 'is_admin': None, 'is_banned': None,
                'is_verified': None, 'last_name': None, 'phone_number': None, 'profile_picture': None,
                'username': 'seller1', 'address': None}, 'status': 'reserved', 'user_username': 'seller1'}
        self.assertEqual(expected, result.json['product'])

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
        self.assertEqual(response.json, {'message': 'Product edited successfully.'})

    def test_edit_product_unauthorized(self):
        """Test unauthorized edit attempt by a non-owner."""
        self.mock_product_query.filter_by.return_value.first.return_value = self.product5
        product_data = {
            'name': 'Laptop unauthorized',
            'price': 500.99,
            'description': 'Updated description',
            'status': 'for sale',
            'category': 'Digital & Electronics',
        }
        with mock.patch("flask_jwt_extended.get_jwt_identity", return_value='current_user'):
            response, status_code = self.product_manager.edit_product(self.user2.username, self.product1.id,
                                                                      product_data)
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.UNAUTHORIZED.value)
        self.assertEqual(response.json, {'message': 'You do not have access to edit this product.'})

    def test_get_products_success(self):
        """Test retrieving a list of products for a user."""
        self.mock_product_query.filter_by.return_value.all.return_value = [
            self.product6, self.product7, self.product8
        ]
        with mock.patch("flask_jwt_extended.get_jwt_identity", return_value='seller2'):
            response, status_code = self.product_manager.get_products('seller2')
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(len(response.json['products']), 3)
        product_ids = [product['id'] for product in response.json['products']]
        self.assertIn(self.product6.id, product_ids)
        self.assertIn(self.product7.id, product_ids)
        self.assertIn(self.product8.id, product_ids)

    def test_get_products_no_products(self):
        """Test retrieving products when no products exist for a user."""
        self.mock_product_query.filter_by.return_value.all.return_value = []
        with mock.patch("flask_jwt_extended.get_jwt_identity", return_value='empty_user'):
            response, status_code = self.product_manager.get_products('empty_user')
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(response.json['products'], [])

    def test_report_product_success(self):
        """Test successfully reporting a product."""
        self.mock_product_query.filter_by.return_value.first.return_value = self.product7
        reporter_username = "seller1"
        report_description = "This product violates policies."
        response, status_code = self.product_manager.report_product(
            reporter_username, self.product1.id, report_description
        )
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(response.json, {'message': 'Product is reported successfully.'})

    def test_report_product_not_found(self):
        """Test reporting a non-existent product."""
        self.mock_product_query.filter_by.return_value.first.return_value = None
        reporter_username = "seller1"
        report_description = "This product violates policies."
        response, status_code = self.product_manager.report_product(
            reporter_username, 999, report_description
        )
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.BAD_REQUEST.value)
        self.assertEqual(response.json, {'message': 'The reported product does not exist.'})

    def test_delete_product_deletes_other_items_too(self):
        user = backend.models.user.User(username='user', password='pass', email='user@gmail.com', is_verified=True)
        product = backend.models.product.Product(id=1, user_username=user.username, name='product', price=10, status='for sale', category='Others')
        product_picture = backend.models.product.Picture(product_id=product.id, filename='picture.jpg')
        product_report = backend.models.report.ProductReport(reported_product=product.id, reporter_username=user.username, description='report')

        self.mock_user_query.filter_by.return_value.first.return_value = user
        self.mock_product_query.filter_by.return_value.all.return_value = [product]
        self.mock_product_picture_query.filter_by.return_value.all.return_value = [product_picture]
        self.mock_product_report_query.filter_by.return_value.all.return_value = [product_report]

        response, status_code = self.product_manager.delete_product(user.username, product.id)

        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.NO_CONTENT.value)

        self.mock_product_picture_query.filter_by(product_id=product.id).delete.assert_called_once()
        self.mock_product_report_query.filter_by(product_id=product.id).delete.assert_called_once()
        self.mock_product_query.filter_by(id=product.id).delete.assert_called_once()


if __name__ == "__main__":
    backend.initializers.test_util.pass_flags_as_parsed()
    absltest.main()
