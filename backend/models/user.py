import backend.initializers.database


class User(backend.initializers.database.DB.Model):
    """
        User model representing a user in the application.
    """

    __tablename__ = 'users'
    USERNAME_MAX_LENGTH = 50
    PASSWORD_MAX_LENGTH = 128
    EMAIL_MAX_LENGTH = 128

    username = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(USERNAME_MAX_LENGTH),
        unique=True,
        nullable=False,
        primary_key=True
    )
    password = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(PASSWORD_MAX_LENGTH),  # TODO: Store it as hashed-value.
        nullable=False
    )
    is_banned = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Boolean,
        default=False
    )
    email = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(EMAIL_MAX_LENGTH),
        unique=True
    )


    def __repr__(self) -> str:
        """
            Return a string representation of the User instance.
        """

        return self.username
