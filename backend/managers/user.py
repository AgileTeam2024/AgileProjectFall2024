from typing import Optional
import datetime

import flask
import flask_jwt_extended

import backend.models.user
import backend.initializers.database
import backend.initializers.settings
import backend.models.user


class UserManager:
    instance = None

    def __init__(self, flask_app: flask.Flask):
        if not UserManager.instance:
            self.flask_app = flask_app
            self.jwt_manager = flask_jwt_extended.JWTManager(flask_app)
            UserManager.instance = self
            # Setup checking revoked tokens.
            import backend.managers.token

    def register(self, username: str, password: str, email: Optional[str] = None) -> (flask.Flask, int):
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
        # check uniqueness of the given email.
        if backend.models.user.User.query.filter_by(email=email).first():
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

        # Generate new access token and refresh token for the user to access protected APIs.
        access_token = flask_jwt_extended.create_access_token(identity=username)
        refresh_token = flask_jwt_extended.create_refresh_token(username)
        response = flask.jsonify({'access_token': access_token, "refresh_token": refresh_token})
        # Set the access token in a cookie with appropriate attributes for cross-origin.
        response.set_cookie(
            'access_token',
            access_token,
            max_age=3600,  # TTL in seconds (1 hour)
            httponly=True,
            secure=False,
            samesite='None'  # Allow cross-origin requests.
        )
        return response, backend.initializers.settings.HTTPStatus.OK.value

    def logout(self, jti: str) -> (flask.Flask, int):
        """
        Revokes current access token of user, and remove it from the cookie.

        Returns:
            tuple: A tuple containing:
                - A Flask response object with a JSON message indicating success.
                - An integer representing the OK HTTP status code (200).
        """
        UserManager._revoke_token(jti)

        # Remove the token from the user cookie.
        response = flask.jsonify({"message": "User logged out successfully."})
        response.set_cookie('access_token', '', expires=0)
        return response, backend.initializers.settings.HTTPStatus.OK.value

    @classmethod
    def _revoke_token(self, jti: str) -> (flask.Flask, int):
        """Revokes a token."""
        revoked_token = backend.models.user.RevokedToken(jti=jti)
        backend.initializers.database.DB.session.add(revoked_token)
        backend.initializers.database.DB.session.commit()

    def refresh_token(self, jti: str, username: str):
        """
        Generate a new access token for the user to access protected APIs, and revoke the previous one.

        Args:
            username (str): The username of the user requesting a new access token.

        Returns:
            response (flask.Response): A Flask response object containing the new access token set in a cookie.
            status_code (int): HTTP status code indicating the result of the operation.
        """
        UserManager._revoke_token(jti)
        # Generate new access token for the user to access protected APIs.
        access_token = flask_jwt_extended.create_access_token(identity=username)
        response = flask.jsonify({'access_token': access_token})
        # Set the access token in a cookie with appropriate attributes for cross-origin.
        response.set_cookie(
            'access_token',
            access_token,
            max_age=3600,  # TTL in seconds (1 hour)
            httponly=True,
            secure=False,
            samesite='None'  # Allow cross-origin requests.
        )
        return response, backend.initializers.settings.HTTPStatus.OK.value
