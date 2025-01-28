import os
import datetime

import flask
import flask_migrate
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
    import backend.models.product
    import backend.models.report

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

        # Applying migration to previous models to update them.
        migrate = flask_migrate.Migrate(flask_app, backend.initializers.database.DB, command='migrate')
        with flask_app.app_context():
            if not os.path.exists(backend.initializers.settings.MIGRATIONS_DIRECTORY):
                flask_migrate.init(backend.initializers.settings.MIGRATIONS_DIRECTORY)
        with flask_app.app_context():
            # Generate a migration script if there are changes.
            flask_migrate.migrate(directory=backend.initializers.settings.MIGRATIONS_DIRECTORY,
                                  message="Auto-generated migration")
            # Apply any pending migrations.
            flask_migrate.upgrade(directory=backend.initializers.settings.MIGRATIONS_DIRECTORY)
    except Exception as e:
        raise Exception("Failed to initialize database: " + str(e))


def create_managers(flask_app: flask.Flask) -> None:
    """Create and initialize application managers.

    Args:
        flask_app (flask.Flask): The Flask application instance used for initializing managers.
    """
    import backend.managers.user
    import backend.managers.product
    import backend.managers.admin

    backend.managers.user.UserManager(flask_app)
    backend.managers.product.ProductManager(flask_app)
    backend.managers.admin.AdminManager(flask_app)


def register_routes(flask_app: flask.Flask) -> None:
    """
    Register application routes with the specified Flask app.

    Args:
        flask_app (flask.Flask): The Flask application instance to which the routes will be registered.
    """
    import backend.routes.user
    import backend.routes.product
    import backend.routes.admin

    flask_app.register_blueprint(backend.routes.user.user_bp, url_prefix='/api/user')
    flask_app.register_blueprint(backend.routes.product.product_bp, url_prefix='/api/product')
    flask_app.register_blueprint(backend.routes.admin.admin_bp, url_prefix='/api/admin')
    # Create authorize button for protected APIs in swagger.
    SWAGGER_TEMPLATE = {
        "securityDefinitions": {"BearerAuth": {"type": "apiKey", "name": "Authorization", "in": "header"}}
    }
    # Create Swagger documentation for APIs.
    flasgger.Swagger(flask_app, template=SWAGGER_TEMPLATE)


def main(_: list[str]) -> None:
    """
       Main entry point for running the Flask application.

       Args:
           _: A list of command-line arguments (not used in this function).
    """

    # Create the Flask app.
    flask_app = flask.Flask(__name__, static_folder='uploads', static_url_path='/backend/uploads')
    # Enable CORS for all routes and origins, since frontend would be hosted in different port from backend.
    flask_cors.CORS(flask_app)
    # Set the server configuration.
    flask_app.config['SERVER_NAME'] = 'pre-loved.ir'
    # Set secret key used for generating tokens.
    flask_app.config['JWT_SECRET_KEY'] = backend.initializers.settings.app_secret_key.value
    # Add location for storing files like images.
    flask_app.config['UPLOAD_FOLDER'] = 'uploads/'
    # Create directory for files if not exists.
    if not os.path.exists('./backend/uploads/'):
        os.makedirs('./backend/uploads/')
    # Set the maximum content length to 16 megabytes.
    flask_app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16 MB
    # Config authentication for protected APIs.
    flask_app.config['JWT_TOKEN_LOCATION'] = ['headers']
    flask_app.config['JWT_ACCESS_TOKEN_EXPIRES'] = datetime.timedelta(minutes=60)
    flask_app.config['JWT_REFRESH_TOKEN_EXPIRES'] = datetime.timedelta(minutes=180)
    # Maximum number of files in a multipart form.
    flask_app.config['MAX_FORM_PARTS'] = 10
    flask_app.config['MAX_FORM_MEMORY_SIZE'] = 50 * 1024 * 1024  # 50 MB
    # Configure verification email settings.
    flask_app.config['MAIL_SERVER'] = backend.initializers.settings.mail_server_host.value
    flask_app.config['MAIL_PORT'] = backend.initializers.settings.mail_server_port.value
    flask_app.config['MAIL_USE_TLS'] = True
    flask_app.config['MAIL_USERNAME'] = backend.initializers.settings.mail_sender_email.value
    flask_app.config['MAIL_PASSWORD'] = backend.initializers.settings.mail_sender_password.value
    flask_app.config['MAIL_DEFAULT_SENDER'] = backend.initializers.settings.mail_sender_email.value
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
