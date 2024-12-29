import flask
import flask_jwt_extended
from typing import Optional

import backend.models.user
import backend.initializers.database
import backend.initializers.settings


class UserManager:
    instance = None

    def __init__(self, flask_app: flask.Flask):
        if not UserManager.instance:
            self.flask_app = flask_app
            self.jwt_manager = flask_jwt_extended.JWTManager(flask_app)
            UserManager.instance = self

    def register(self, username: str, password: str, email: Optional[str]) -> (flask.Flask, int):
        """
        Registers a new user with the provided username and password.

        This method checks if the given username is unique. If the username already exists,
        it returns an error message indicating that the username is taken. If the username
        is unique, it creates a new user instance, hashes the provided password, and saves
        the user to the database.

        Args:
            username (str): The desired username for the new user.
            password (str): The password for the new user account.
            email (str): the email for the new user account

        Returns:
            tuple: A tuple containing:
                - A Flask response object with a JSON message indicating success or failure.
                - An integer representing the HTTP status code (e.g., 201 for created, 400 for bad request).
        """
        # Check uniqueness of the given username.
        if backend.models.user.User.query.filter_by(username=username).first():
            return (
                flask.jsonify({'message': 'Username already exists'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )
        if email and backend.models.user.User.query.filter_by(email=email).first():
            return (
                flask.jsonify({'message': 'Email already exists'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )

        # Create a new user instance.
        # TODO: Store password as hashed-value.
        new_user = backend.models.user.User(username=username, password=password, email=email)

        # Add the new user to the database.
        backend.initializers.database.DB.session.add(new_user)
        backend.initializers.database.DB.session.commit()
        return (
            flask.jsonify({"message": "User registered successfully."}),
            backend.initializers.settings.HTTPStatus.CREATED.value
        )

    def login(self, username: str, password: str) -> (flask.Flask, int):
        """
            Authenticates a user by verifying the provided username and password.

            This method checks if a user with the given username exists in the database.
            If the user exists, it verifies the provided password against the stored hashed password.
            Upon successful authentication, it generates a JWT access token for the user.

        Args:
            username (str): The username of the user attempting to log in.
            password (str): The password provided by the user for authentication.

        Returns:
            tuple: A tuple containing:
                - A Flask response object with a JSON message indicating success or failure.
                - An integer representing the HTTP status code (e.g., 200 for OK, 400
        """
        user = backend.models.user.User.query.filter_by(username=username).first()
        # Check if a user with the given username exists.
        if not user:
            return (
                flask.jsonify({'message': 'Username and password do not match.'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )
        # Check whether password is correct.
        # TODO: Compare hash instead of actual password.
        if user.password != password:
            return (
                flask.jsonify({'message': 'Username and password do not match.'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )

        # Generate new access token for the user to access protected APIs.
        access_token = flask_jwt_extended.create_access_token(identity=username)
        return (
            flask.jsonify({'access_token': access_token}),
            backend.initializers.settings.HTTPStatus.OK.value
        )
