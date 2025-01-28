import os

import flask
import flask_migrate
from absl import app as absl_app

# Load settings for the defined flags to be parsed before running the app.
# This ensures that any required configurations are available when initializing the Flask app.
import backend.initializers.settings


def generate_migration_file(flask_app: flask.Flask) -> None:
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
            # Generate a migration script if there are changes.
            flask_migrate.migrate(directory=backend.initializers.settings.MIGRATIONS_DIRECTORY,
                                  message="Auto-generated migration")
    except Exception as e:
        raise Exception("Failed to initialize database: " + str(e))


def main(_: list[str]) -> None:
    flask_app = flask.Flask(__name__)
    try:
        generate_migration_file(flask_app)
    except Exception as e:
        flask_app.logger.error(f"An error occurred while generating the migration file: {str(e)}")
        exit(1)


if __name__ == '__main__':
    absl_app.run(main)
