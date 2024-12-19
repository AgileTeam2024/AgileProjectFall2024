import re

import flask
import flask_wtf
import wtforms

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
      - name: username
        type: string
        required: true
        description: The username of the new user.
      - name: password
        type: string
        required: true
        description: The password for the new user.
    responses:
      201:
        description: User registered successfully.
      400:
        description: Invalid input or username exists.
    """

    # Check existence of username and password.
    query_params = flask.request.args.to_dict()
    username = query_params.get('username', '')
    if not username:
        return (
            flask.jsonify({'message': 'Username is missing.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    password = query_params.get('password', '')
    if not password:
        return (
            flask.jsonify({'message': 'Password is missing.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    return backend.managers.user.UserManager.instance.register(username, password)


@user_bp.route('/login', methods=['GET'])
def login() -> (flask.Flask, int):
    """
    User Login API.
    ---
    tags:
      - User
    parameters:
      - name: username
        type: string
        required: true
        description: The username of the new user.
      - name: password
        type: string
        required: true
        description: The password for the new user.
    responses:
      200:
        description: User logged in successfully.
      400:
        description: Invalid input or username and password do not match.
    """

    # Check existence of username and password.
    query_params = flask.request.args.to_dict()
    username = query_params.get('username', '')
    if not username:
        return (
            flask.jsonify({'message': 'Username is missing.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    password = query_params.get('password', '')
    if not password:
        return (
            flask.jsonify({'message': 'Password is missing.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    return backend.managers.user.UserManager.instance.login(username, password)
