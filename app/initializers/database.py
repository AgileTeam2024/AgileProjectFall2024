from flask_sqlalchemy import SQLAlchemy

import app.initializers.settings


class DatabaseConfig:
    """
    Configuration class for setting up the SQLAlchemy database connection.
    """

    SQLALCHEMY_DATABASE_URI = (
        f"postgresql://"
        f"{app.initializers.settings.db_username.value}:{app.initializers.settings.db_password.value}"
        f"@{app.initializers.settings.db_host.value}:{app.initializers.settings.db_port.value}"
        f"/{app.initializers.settings.db_name.value}"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False


# DB is an instance of SQLAlchemy to interact with the database.
DB = SQLAlchemy()
