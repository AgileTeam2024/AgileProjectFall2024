import email_validator
import flask
import flask_jwt_extended
import werkzeug.utils

import backend.managers.user
import backend.models.user
import backend.initializers.settings
import backend.routes.authorization_utils

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


@user_bp.route('/confirm_email/<token>', methods=['GET'])
def confirm_email(token) -> (flask.Flask, int):
    """
    Confirm Email API.
    ---
    tags:
      - User
    parameters:
        - name: token
          in: path
          type: string
          required: true
          description: The token used for confirming the email address.
    responses:
      200:
        description: Email verified successfully.
      403:
        description: Email did not verify.
    """
    return backend.managers.user.UserManager.instance.confirm_email(token)


@user_bp.route('/resend_email', methods=['POST'])
def resend_email() -> (flask.Flask, int):
    """
    Resend Email API.
    ---
    tags:
      - User
    parameters:
        - name: username
          in: formData
          type: string
          required: true
          description: The email address to send verification email to.
    responses:
      200:
        description: Email sent successfully.
    """
    username = flask.request.form.get('username')
    if not username:
        return (
            flask.jsonify({'message': 'Username is missing.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    return backend.managers.user.UserManager.instance.resend_confirmation_email(username)


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


@user_bp.route('/logout', methods=['DELETE'])
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
@backend.routes.authorization_utils.valid_user
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


@user_bp.route('/delete', methods=['DELETE'])
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


@user_bp.route('/get_profile', methods=['GET'])
@flask_jwt_extended.jwt_required()
@backend.routes.authorization_utils.valid_user
def get_profile() -> (flask.Flask, int):
    """
    User get own profile API.
    ---
    tags:
      - User
    security:
      - BearerAuth: []
    responses:
      200:
        description: Successfully get own profile.
    """
    return backend.managers.user.UserManager.instance.get_profile(flask_jwt_extended.get_jwt_identity())


@user_bp.route('/get_profile_by_username/<username>', methods=['GET'])
def get_profile_by_username(username) -> (flask.Flask, int):
    """
    User get profile by username API.
    ---
    tags:
      - User
    parameters:
      - name: username
        in: path
        type: string
        required: true
        description: Username of user to get profile for.
    responses:
      200:
        description: Successfully get profile by username.
    """
    return backend.managers.user.UserManager.instance.get_profile(username)


@user_bp.route('/edit_profile', methods=['PUT'])
@flask_jwt_extended.jwt_required()
@backend.routes.authorization_utils.valid_user
def edit() -> (flask.Flask, int):
    """
    User edit profile API.
    ---
    tags:
      - User
    security:
      - BearerAuth: []
    parameters:
      - name: first_name
        in: formData
        required: false
        type: string
        description: The first name of the user.
      - name: last_name
        in: formData
        required: false
        type: string
        description: The last name of the user.
      - name: phone number
        in: formData
        required: false
        type: string
        description: The phone number of the user.
      - name: address
        in: formData
        required: false
        type: string
        description: The address of the user.
      - name: profile_picture
        in: formData
        type: file
        required: false
        description: The profile picture of the user.
    responses:
      200:
        description: Successfully edited the user
    """
    info = {}
    # Get new values of profile fields.
    first_name = flask.request.form.get('first_name')
    if first_name:
        info['first_name'] = first_name
    last_name = flask.request.form.get('last_name')
    if last_name:
        info['last_name'] = last_name
    phone_number = flask.request.form.get('phone_number')
    if phone_number:
        info['phone_number'] = phone_number
    address = flask.request.form.get('address')
    if address:
        info['address'] = address
    # Get the new profile picture.
    profile_picture = flask.request.files.get('profile_picture')
    if (profile_picture and '.' in profile_picture.filename and
            profile_picture.filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg', 'gif'}):
        filename = werkzeug.utils.secure_filename(profile_picture.filename)
        info['image'] = profile_picture
        info['image_filename'] = filename
    return backend.managers.user.UserManager.instance.edit_profile(flask_jwt_extended.get_jwt_identity(), info)


@user_bp.route('/report_user', methods=['POST'])
@flask_jwt_extended.jwt_required()
@backend.routes.authorization_utils.valid_user
def report_user() -> (flask.Flask, int):
    """
    Report a user for inappropriate behavior.
    ---
    tags:
      - User
    security:
      - BearerAuth: []
    parameters:
      - name: reported_username
        in: formData
        type: string
        required: true
        description: The username of the user being reported.
      - name: description
        in: formData
        type: string
        required: true
        description: A description of the reason for reporting the user.
    responses:
      200:
        description: User is reported successfully.
      400:
        description: Bad request. Missing required fields.
    """
    reported_username = flask.request.form.get('reported_username')
    if not reported_username:
        return (
            flask.jsonify({'message': 'Missing reported username.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    description = flask.request.form.get('description')
    if not description:
        return (
            flask.jsonify({'message': 'Missing description.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    return backend.managers.user.UserManager.instance.report_user(flask_jwt_extended.get_jwt_identity(),
                                                                  reported_username, description)
