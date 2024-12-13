from flask import Flask


def create_flask_app() -> Flask:
    """
        Create and configure a Flask application.

        This function initializes a Flask application, configures it to connect
        to a database using SQLAlchemy, and creates the necessary database tables
        based on defined models if they do not already exist.

        Returns:
            Flask: The configured Flask application instance.
    """

    import app.initializers.database

    flask_app = Flask(__name__)
    # Make connection to the database.
    flask_app.config.from_object(app.initializers.database.DatabaseConfig)
    app.initializers.database.DB.init_app(flask_app)
    # Create corresponding tables of models in database, If they don't already exist.
    with flask_app.app_context():
        app.initializers.database.DB.create_all()

    return flask_app
