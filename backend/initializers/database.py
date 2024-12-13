from flask_sqlalchemy import SQLAlchemy

import backend.initializers.settings


class DatabaseConfig:
    """
    Configuration class for setting up the SQLAlchemy database connection.
    """

    SQLALCHEMY_DATABASE_URI = (
        f"postgresql://"
        f"{backend.initializers.settings.db_username.value}:{backend.initializers.settings.db_password.value}"
        f"@{backend.initializers.settings.db_host.value}:{backend.initializers.settings.db_port.value}"
        f"/{backend.initializers.settings.db_name.value}"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False


# DB is an instance of SQLAlchemy to interact with the database.
DB = SQLAlchemy()
