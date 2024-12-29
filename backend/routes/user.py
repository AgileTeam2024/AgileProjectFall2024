import re

import flask
import flask_wtf
import wtforms
import flask_jwt_extended

import backend.managers.user
import backend.models.user
import backend.initializers.settings

user_bp = flask.Blueprint('user', __name__)


@user_bp.route('/register', methods=['POST'])
def register() -> (flask.Flask, int):
    """
    User Registration API.
    ---
    tags:
      - User
    parameters:
      - name: user
        in: body
        required: true
        schema:
          type: object
          properties:
            username:
              type: string
              description: The username of the new user.
              example: "new_user"
            password:
              type: string
              description: The password for the new user.
              example: "secure_password"
    responses:
      201:
        description: User registered successfully.
      400:
        description: Invalid input or username exists.
    """

    # Get JSON data from the request body.
    data = flask.request.get_json()
    regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    # Check existence of username and password.
    username = data.get('username', '')
    if not username:
        return (
            flask.jsonify({'message': 'Username is missing.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    password = data.get('password', '')
    if not password:
        return (
            flask.jsonify({'message': 'Password is missing.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    email = data.get('email', '')
    if not email:
        return (
            flask.jsonify({'message': 'Email is missing.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
      )

    return backend.managers.user.UserManager.instance.register(username, password, email)


@user_bp.route('/login', methods=['POST'])  # Changed to POST
def login() -> (flask.Flask, int):
    """
    User Login API.
    ---
    tags:
      - User
    parameters:
      - name: user
        in: body
        required: true
        schema:
          type: object
          properties:
            username:
              type: string
              description: The username of the user.
              example: "existing_user"
            password:
              type: string
              description: The password for the user.
              example: "secure_password"
    responses:
      200:
        description: User logged in successfully.
      400:
        description: Invalid input or username and password do not match.
    """

    # Get JSON data from the request body.
    data = flask.request.get_json()

    # Check existence of username and password.
    username = data.get('username', '')
    if not username:
        return (
            flask.jsonify({'message': 'Username is missing.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    password = data.get('password', '')
    if not password:
        return (
            flask.jsonify({'message': 'Password is missing.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )

    return backend.managers.user.UserManager.instance.login(username, password)


@user_bp.route('/check_cookie', methods=['GET'])
@flask_jwt_extended.jwt_required()
def check_cookie():
   pass