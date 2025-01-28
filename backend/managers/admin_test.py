from unittest import mock

import flask
import flask_jwt_extended
from absl.testing import absltest

import backend.managers.admin
import backend.models.report
import backend.models.user
import backend.initializers.settings
import backend.initializers.test_util


class UserManagerTest(absltest.TestCase):
    def setUp(self) -> None:
        super().setUp()
        self.flask_app = flask.Flask(__name__)
        self.flask_app.config['JWT_SECRET_KEY'] = 'app_secret_key'
        self.jwt_manager = flask_jwt_extended.JWTManager(self.flask_app)
        self.flask_app.app_context().push()
        self.admin_manager = backend.managers.admin.AdminManager(flask_app=self.flask_app)
        # Mock database session.
        self.mock_db_session = mock.patch("backend.initializers.database.DB.session").start()
        # Mock query on models.
        self.mock_product_report_query = mock.patch("backend.models.report.ProductReport.query").start()
        self.mock_user_report_query = mock.patch("backend.models.report.UserReport.query").start()
        self.mock_user_query = mock.patch("backend.models.user.User.query").start()
        self.mock_product_query = mock.patch("backend.models.product.Product.query").start()

    def tearDown(self) -> None:
        self.mock_db_session.stop()
        self.mock_product_report_query.stop()
        self.mock_user_report_query.stop()
        self.mock_user_query.stop()
        super().tearDown()

    def test_get_product_report_list(self) -> None:
        """Test getting product report list successfully."""
        self.mock_product_report_query.all.return_value = [
            backend.models.report.ProductReport(
                id=1, reported_product=1, reporter_username="username1", description="description1"
            ),
            backend.models.report.ProductReport(
                id=2, reported_product=2, reporter_username="username2", description="description2"
            )
        ]
        response, status_code = self.admin_manager.get_list_of_reported_products()
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(
            response.json,
            {
                'reported_products': [
                    {
                        'description': 'description1',
                        'id': 1,
                        'reported_product': 1,
                        'reporter_username': 'username1'
                    },
                    {
                        'description': 'description2',
                        'id': 2,
                        'reported_product': 2,
                        'reporter_username': 'username2'
                    }
                ]
            }
        )

    def test_get_user_report_list(self) -> None:
        """Test getting user report list successfully."""
        self.mock_user_report_query.all.return_value = [
            backend.models.report.UserReport(
                id=1, reported_user="username1", reporter_username="username2", description="description1"
            ),
            backend.models.report.UserReport(
                id=2, reported_user="username3", reporter_username="username4", description="description2"
            )
        ]
        response, status_code = self.admin_manager.get_list_of_reported_users()
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(
            response.json,
            {
                'reported_users': [
                    {
                        'description': 'description1',
                        'id': 1,
                        'reported_user': "username1",
                        'reporter_username': 'username2'
                    },
                    {
                        'description': 'description2',
                        'id': 2,
                        'reported_user': "username3",
                        'reporter_username': 'username4'
                    }
                ]
            }
        )

    def test_ban_user(self) -> None:
        """Test banning user successfully."""
        user = backend.models.user.User(
            username="username",
            password="password",
            is_banned=False
        )
        self.mock_user_query.filter_by.return_value.first.return_value = user
        response, status_code = self.admin_manager.ban_user(username=user.username)
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(response.json, {"message": "User banned successfully."})
        self.assertTrue(user.is_banned)

    def test_ban_user_does_not_exist(self) -> None:
        """Test non-existent banning user fails."""
        self.mock_user_query.filter_by.return_value.first.return_value = None
        response, status_code = self.admin_manager.ban_user('user1')
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.NOT_FOUND.value)
        self.assertEqual(response.json, {"message": "User not found."})

    def test_ban_product(self) -> None:
        """Test banning product successfully."""
        product = backend.models.product.Product(id=1, is_banned=False)
        self.mock_product_query.filter_by.return_value.first.return_value = product
        response, status_code = self.admin_manager.ban_product(product.id)
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(response.json, {"message": "Product banned successfully."})
        self.assertTrue(product.is_banned)

    def test_ban_product_does_not_exist(self) -> None:
        """Test non-existent banning product fails."""
        self.mock_product_query.filter_by.return_value.first.return_value = None
        response, status_code = self.admin_manager.ban_product(1)
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.NOT_FOUND.value)
        self.assertEqual(response.json, {"message": "Product not found."})

    def test_unban_user(self) -> None:
        """Test unbanning user successfully."""
        user = backend.models.user.User(
            username="username",
            password="password",
            is_banned=True
        )
        self.mock_user_query.filter_by.return_value.first.return_value = user
        response, status_code = self.admin_manager.unban_user(username=user.username)
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(response.json, {"message": "User unbanned successfully."})
        self.assertFalse(user.is_banned)

    def test_get_banned_products_list(self) -> None:
        """Test get list of banned products."""
        products = [backend.models.product.Product(id=1, is_banned=True),
                    backend.models.product.Product(id=2, is_banned=True),
                    backend.models.product.Product(id=3, is_banned=True)]
        self.mock_product_query.filter_by.return_value.all.return_value = products
        response, status_code = self.admin_manager.get_banned_product_list()
        self.assertEqual(status_code, backend.initializers.settings.HTTPStatus.OK.value)
        self.assertEqual(response.json, {'banned_products': [{'category': None, 'city_name': None, 'created_at': None, 'description': None, 'id': 1, 'name': None, 'pictures': [], 'price': None, 'status': None, 'user_username': None, 'is_banned': True},
                                                                     {'category': None, 'city_name': None, 'created_at': None, 'description': None, 'id': 2, 'name': None, 'pictures': [], 'price': None, 'status': None, 'user_username': None, 'is_banned': True},
                                                                     {'category': None, 'city_name': None, 'created_at': None, 'description': None, 'id': 3, 'name': None, 'pictures': [], 'price': None, 'status': None, 'user_username': None, 'is_banned': True}]})


if __name__ == "__main__":
    backend.initializers.test_util.pass_flags_as_parsed()
    absltest.main()
