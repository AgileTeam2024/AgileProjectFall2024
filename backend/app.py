from flask import Flask
from absl import app as absl_app

# Load settings for the defined flags to be parsed before running the app.
# This ensures that any required configurations are available when initializing the Flask app.
import backend.initializers.settings


def create_flask_app() -> Flask:
    """
        Create and configure a Flask application.

        This function initializes a Flask application, configures it to connect
        to a database using SQLAlchemy, and creates the necessary database tables
        based on defined models if they do not already exist.

        Returns:
            Flask: The configured Flask application instance.
    """

    import backend.initializers.database

    flask_app = Flask(__name__)
    # Make connection to the database.
    flask_app.config.from_object(backend.initializers.database.DatabaseConfig)
    backend.initializers.database.DB.init_app(flask_app)
    # Create corresponding tables of models in database, If they don't already exist.
    with flask_app.app_context():
        backend.initializers.database.DB.create_all()

    return flask_app


def main(_: list[str]) -> None:
    """
       Main entry point for running the Flask application.

       Args:
           _: A list of command-line arguments (not used in this function).
    """

    # TODO: Use "waitress" to run the app in production.
    # This TODO is done when local deployment is done, and the app is production-ready.
    create_flask_app().run(host='0.0.0.0', port=8000)


if __name__ == '__main__':
    absl_app.run(main)
