import backend.initializers.database


class Cookie(backend.initializers.database.DB.Model):
    """
        User model representing a user in the application.
    """

    __tablename__ = 'cookies'
    USERNAME_MAX_LENGTH = 50
    COOKIE_MAX_LENGTH = 356

    username = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(USERNAME_MAX_LENGTH),
        unique=True,
        nullable=False,
        primary_key=True
    )
    cookie = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(COOKIE_MAX_LENGTH),  # TODO: Store it as hashed-value.
        nullable=False
    )

    def __repr__(self) -> str:
        """
            Return a string representation of the User instance.
        """

        return self.username
