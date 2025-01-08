import sqlalchemy

import backend.initializers.database


class User(backend.initializers.database.DB.Model):
    """
        User model representing a user in the application.
    """

    __tablename__ = 'users'
    USERNAME_MAX_LENGTH = 50
    PASSWORD_MAX_LENGTH = 128
    EMAIL_MAX_LENGTH = 128
    COOKIE_MAX_LENGTH = 356

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
        unique=True,
        nullable=False
    )
    first_name = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String,
        nullable=True
    )
    last_name = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String,
        nullable=True
    )
    phone_number = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String,
        nullable=True
    )
    address = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String,
        nullable=True
    )
    profile_picture = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String,
        nullable=True
    )

    def __repr__(self) -> str:
        """
            Return a string representation of the User instance.
        """
        return self.username

    def to_dict(self) -> dict:
        """Convert the User instance to a dictionary for JSON serialization."""
        return {
            'username': self.username,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'phone_number': self.phone_number,
            'profile_picture': self.profile_picture,
            'is_banned': self.is_banned,
            'email': self.email,
        }


class ProfilePicture(backend.initializers.database.DB.Model):
    """
    Represents a user's picture.
    """
    id = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Integer,
        primary_key=True,
        autoincrement=True
    )
    filename = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(255),
        nullable=False
    )
    user_username = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String,
        backend.initializers.database.DB.ForeignKey('users.username'),
        nullable=False
    )

    def to_dict(self) -> dict:
        return {
            'id': self.id,
            'filename': self.filename
        }


class RevokedToken(backend.initializers.database.DB.Model):
    """Represents a revoked JWT token."""
    jti = backend.initializers.database.DB.Column(backend.initializers.database.DB.String(36), primary_key=True)
    revoked_at = backend.initializers.database.DB.Column(
        sqlalchemy.DateTime,
        server_default=sqlalchemy.func.now()
    )

    def __repr__(self):
        return f"<RevokedToken {self.jti}>"
