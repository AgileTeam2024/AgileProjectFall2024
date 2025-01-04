import email_validator
import flask
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
            email:
              type: string
              description: The email for the new user.
              example: "email@example.com"
    responses:
      201:
        description: User registered successfully.
      400:
        description: Invalid input or username exists.
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
    email = data.get('email', '')
    if not email:
        return (
            flask.jsonify({'message': 'Email is missing.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    # Validate the email.
    try:
        email_validator.validate_email(email)
    except email_validator.EmailNotValidError as e:
        return (
            flask.jsonify({'message': 'Email is invalid.'}),
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


@user_bp.route('/logout', methods=['GET'])
@flask_jwt_extended.jwt_required()
def logout():
    """
    User logout API.
    ---
    tags:
      - User
    security:
      - BearerAuth: []
    responses:
      200:
        description: Successfully logged out
      401:
        description: Token has expired or is invalid
    """
    return backend.managers.user.UserManager.instance.logout(flask_jwt_extended.get_jwt()['jti'])


@user_bp.route('/refresh', methods=['GET'])
@flask_jwt_extended.jwt_required(refresh=True)
def refresh_token() -> (flask.Flask, int):
    """
    Refresh access token API.
    ---
    tags:
      - User
    security:
      - BearerAuth: []
    responses:
      200:
        description: Successfully refreshed access token
      401:
        description: Token has expired or is invalid
      403:
        description: Refresh token is required but not provided or invalid
    """
    return backend.managers.user.UserManager.instance.refresh_token(flask_jwt_extended.get_jwt()["jti"],
                                                                    flask_jwt_extended.get_jwt_identity())


@user_bp.route('/delete', methods=['GET'])
@flask_jwt_extended.jwt_required()
def delete_user() -> (flask.Flask, int):
    """
    User delete API.
    ---
    tags:
      - User
    security:
      - BearerAuth: []
    responses:
      200:
        description: Successfully deleted the user
    """
    return backend.managers.user.UserManager.instance.delete_account(flask_jwt_extended.get_jwt_identity())
