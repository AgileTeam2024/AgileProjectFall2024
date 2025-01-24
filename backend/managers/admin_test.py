from unittest import mock

import flask
import flask_jwt_extended
from absl.testing import absltest

import backend.managers.admin
import backend.models.report
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

    def tearDown(self) -> None:
        self.mock_db_session.stop()
        self.mock_product_report_query.stop()
        self.mock_user_report_query.stop()
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


if __name__ == "__main__":
    backend.initializers.test_util.pass_flags_as_parsed()
    absltest.main()
