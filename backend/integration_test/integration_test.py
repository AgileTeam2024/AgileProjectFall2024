import requests

from absl.testing import absltest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

import backend.models.user
import backend.initializers.settings


class IntegrationTest(absltest.TestCase):
    REGISTER_API = "http://flask_app_integration:5000/api/user/register"
    DATABASE_URI = (
        f"postgresql://"
        f"postgres:postgres"
        f"@flask_db_integration:5432"
        f"/test"
    )

    @classmethod
    def setUpClass(cls):
        # Set up database connection for testing.
        cls.engine = create_engine(cls.DATABASE_URI)
        cls.Session = sessionmaker(bind=cls.engine)

    def test_register_and_login(self):
        response = requests.post(self.REGISTER_API,
                                 json={'username': 'username2', 'password': 'password', 'email': 'user2@gmail.com'})
        self.assertEqual(response.status_code, backend.initializers.settings.HTTPStatus.CREATED.value)

        session = self.Session()
        user = session.query(backend.models.user.User).filter_by(username='username2').first()
        # Assert that the user exists in the database.
        self.assertIsNotNone(user)
        self.assertEqual(user.username, 'username2')


if __name__ == "__main__":
    absltest.main()
