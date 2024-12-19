import flask
import flask_cors
import flasgger
from absl import app as absl_app

# Load settings for the defined flags to be parsed before running the app.
# This ensures that any required configurations are available when initializing the Flask app.
import backend.initializers.settings


def connect_to_db(flask_app: flask.Flask) -> None:
    """
    Connect to the database and initialize the database models.

    This function configures the provided Flask application to connect
    to a database using SQLAlchemy. It also creates the necessary database
    tables based on defined models if they do not already exist.

    Args:
        flask_app (Flask): The Flask application instance to configure.

    Raises:
        Exception: If the database initialization fails.
    """

    import backend.initializers.database
    # Load database models to ensure their tables existence.
    import backend.models.user

    # Configure the Flask app for setting up the SQLAlchemy database connection.
    flask_app.config['SQLALCHEMY_DATABASE_URI'] = (
        f"postgresql://"
        f"{backend.initializers.settings.db_username.value}:{backend.initializers.settings.db_password.value}"
        f"@{backend.initializers.settings.db_host.value}:{backend.initializers.settings.db_port.value}"
        f"/{backend.initializers.settings.db_name.value}"
    )
    flask_app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    try:
        # Make connection to the database with the provided config.
        backend.initializers.database.DB.init_app(flask_app)
        # Create corresponding tables of models in database, If they don't already exist.
        with flask_app.app_context():
            backend.initializers.database.DB.create_all()
    except Exception as e:
        raise Exception("Failed to initialize database: " + str(e))


def create_managers(flask_app: flask.Flask) -> None:
    """Create and initialize application managers.

    Args:
        flask_app (flask.Flask): The Flask application instance used for initializing managers.
    """
    import backend.managers.user

    backend.managers.user.UserManager(flask_app)


def register_routes(flask_app: flask.Flask) -> None:
    """
    Register application routes with the specified Flask app.

    Args:
        flask_app (flask.Flask): The Flask application instance to which the routes will be registered.
    """
    import backend.routes.user

    flask_app.register_blueprint(backend.routes.user.user_bp, url_prefix='/user')
    # Create Swagger documentation for APIs.
    flasgger.Swagger(flask_app)


def main(_: list[str]) -> None:
    """
       Main entry point for running the Flask application.

       Args:
           _: A list of command-line arguments (not used in this function).
    """

    # Create the Flask app.
    flask_app = flask.Flask(__name__)
    # Enable CORS for all routes and origins, since frontend would be hosted in different port from backend.
    flask_cors.CORS(flask_app)
    # Set secret key used for generating tokens.
    flask_app.config['JWT_SECRET_KEY'] = backend.initializers.settings.app_secret_key.value
    # Create application managers.
    create_managers(flask_app)
    # Register routers blueprint.
    register_routes(flask_app)
    try:
        # Make connection to the database.
        connect_to_db(flask_app)

        # Run the Flask app.
        # TODO: Use "waitress" to run the app in production.
        # This TODO is done when local development is done, and the app is production-ready.
        flask_app.run(
            host=backend.initializers.settings.app_host.value,
            port=backend.initializers.settings.app_port.value,
        )
    except Exception as e:
        # Log the error, and gracefully shutdown the app, if an exception raised.
        flask_app.logger.error(f"An error occurred while starting the application: {str(e)}")
        exit(1)


if __name__ == '__main__':
    absl_app.run(main)
