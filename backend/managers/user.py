import flask
import flask_jwt_extended
from typing import Optional
import re
import datetime

import backend.models.user
import backend.models.cookie
import backend.initializers.database
from flask import request


class UserManager:
    instance = None

    COOKIE_MAX_AGE = datetime.timedelta(days=1).seconds

    def __init__(self, flask_app: flask.Flask):
        if not UserManager.instance:
            self.flask_app = flask_app
            self.jwt_manager = flask_jwt_extended.JWTManager(flask_app)
            flask_app.config["JWT_COOKIE_SECURE"] = False
            flask_app.config["JWT_TOKEN_LOCATION"] = ["cookies"]
            flask_app.config["JWT_ACCESS_TOKEN_EXPIRES"] = datetime.timedelta(seconds=UserManager.COOKIE_MAX_AGE)
            flask_app.config["JWT_SESSION_COOKIE"] = UserManager.COOKIE_MAX_AGE
            UserManager.instance = self

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
        if email:
            if backend.models.user.User.query.filter_by(email=email).first():
                return (
                    flask.jsonify({'message': 'Email already exists'}),
                    backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
                )
            if not is_valid_email_regex(email):
                return (
                    flask.jsonify({'message': 'Email must be the correct format.'}),
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
        
        response = flask.make_response(flask.jsonify({'message': 'Login successful!'}))

        # Generate new access token for the user to access protected APIs.
        self.set_cookie(response, username)

        return (
            response,
            backend.initializers.settings.HTTPStatus.OK.value
        )

    def set_cookie(self, response, username):
        self.delete_cookie_if_exists(username)

        access_token = flask_jwt_extended.create_access_token(username)
        print(len(access_token))
        flask_jwt_extended.set_access_cookies(response, access_token)
        new_cookie = backend.models.cookie.Cookie(username=username, cookie=access_token)

        # Add the new cookie to the database.
        backend.initializers.database.DB.session.add(new_cookie)
        backend.initializers.database.DB.session.commit()

    def reset_cookie(self, response):
        username = flask_jwt_extended.get_jwt_identity()
        self.set_cookie(response, username)

    def remove_cookie(self, response):
        username = flask_jwt_extended.get_jwt_identity()
        self.delete_cookie_if_exists(username)
        flask_jwt_extended.unset_access_cookies(response)

    def check_cookie(self) -> (flask.Flask, int):
        cookie = request.cookies.get("access_token_cookie")
        cookie = backend.models.cookie.Cookie.query.filter_by(cookie=cookie).first()
        if not cookie:
            return (
                flask.jsonify({"msg": "Token is invalid."}),
                backend.initializers.settings.HTTPStatus.UNAUTHORIZED.value
            )
        return (
            flask.jsonify({"message": "Token is valid."}),
            backend.initializers.settings.HTTPStatus.OK.value
        )

    def delete_cookie_if_exists(self, username):
        cookie = backend.models.cookie.Cookie.query.filter_by(username=username).first()
        if cookie:
            backend.initializers.database.DB.session.delete(cookie)
            backend.initializers.database.DB.session.commit()


def is_valid_email_regex(email):
    regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if re.fullmatch(regex, email):
        return True
    return False