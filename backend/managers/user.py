import os
import datetime
import itsdangerous
from typing import Optional

import flask
import flask_mail
import flask_jwt_extended

import backend.models.user
import backend.initializers.database
import backend.initializers.settings
import backend.models.product
import backend.models.report


class UserManager:
    instance = None

    def __init__(self, flask_app: flask.Flask):
        if not UserManager.instance:
            self.flask_app = flask_app
            self.jwt_manager = flask_jwt_extended.JWTManager(flask_app)
            self.email_serializer = itsdangerous.URLSafeTimedSerializer(flask_app.config['JWT_SECRET_KEY'])
            self.mail_service = flask_mail.Mail(flask_app)
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

        # Send the confirmation email.
        self._send_confirmation_email(email)

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

    def _send_confirmation_email(self, email: str) -> None:
        # Generate confirmation token for verification email.
        email_token = self.email_serializer.dumps(email, salt='email-confirm')
        # Generate verification email content.
        confirm_url = "https://" + self.flask_app.config['SERVER_NAME'] + "/api/user/confirm_email/" + email_token
        subject = "Pre-Loved verification email"
        text_body = f'''
                Thank you for registering. Please confirm your email by clicking the link below:

                {confirm_url}

                If you did not create an account, please ignore this email.

                Best regards,
                Pre-Loved
                '''
        # Create the message.
        msg = flask_mail.Message(
            subject,
            recipients=[email],
            body=text_body,
            sender=self.flask_app.config['MAIL_USERNAME']
        )
        # Send the email.
        self.mail_service.send(msg)

    def confirm_email(self, email_token: str) -> (flask.Flask, int):
        """
        Confirms the given email verification token and verifies the user.
        Args:
            email_token(str): The token to verify the user.

        Returns:
            tuple: A tuple containing:
                - A Flask response object with a JSON message indicating success or failure.
                - An integer representing the HTTP status code (200 or 403).
        """
        try:
            email = self.email_serializer.loads(email_token, salt='email-confirm', max_age=3600)
        except Exception as e:
            return (
                flask.jsonify({"message": "Verification failed.", "error": str(e)}),
                backend.initializers.settings.HTTPStatus.FORBIDDEN.value
            )
        # Verify the user's email by setting 'is_verified' attribute to True.
        user = backend.models.user.User.query.filter_by(email=email).first()
        user.is_verified = True
        backend.initializers.database.DB.session.add(user)
        backend.initializers.database.DB.session.commit()
        return (
            flask.jsonify({"message": "Email verified successfully."}),
            backend.initializers.settings.HTTPStatus.OK.value
        )

    def resend_confirmation_email(self, email: str) -> (flask.Flask, int):
        """
        Resends the confirmation email to the provided email address.
        Args:
            email(str): The email address to send verification email to.

        Returns:
            tuple: A tuple containing:
                - A Flask response object with a JSON message indicating success.
                - An integer representing the HTTP status code 200.
        """
        self._send_confirmation_email(email)
        return (
            flask.jsonify({"message": "Verification email resent."}),
            backend.initializers.settings.HTTPStatus.OK.value
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
        # Check whether user is banned or not.
        if user.is_banned:
            return (
                flask.jsonify({'message': 'You are banned.'}),
                backend.initializers.settings.HTTPStatus.FORBIDDEN.value
            )
        # Check whether user verified his/her email or not.
        if not user.is_verified:
            return (
                flask.jsonify({'message': 'You should verify your email first.'}),
                backend.initializers.settings.HTTPStatus.FORBIDDEN.value
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

    def delete_account(self, username: str) -> (flask.Flask, int):
        """
        Deletes a user's account.
        By deleting user's account, every other items belonged to that user would be deleted, too.

        Args:
            username (str): The username of the user.

        Returns:
            response (flask.Response): A Flask response object containing successfully deleted a user.
            status_code (int): HTTP status code indicating success (200).
        """
        products_to_delete = backend.models.product.Product.query.filter_by(user_username=username).all()
        for product in products_to_delete:
            print(backend.managers.product.ProductManager.instance.delete_product(username, product.id)[1] == 204)

        backend.models.user.ProfilePicture.query.filter_by(user_username=username).delete()

        backend.models.report.UserReport.query.filter_by(reported_user=username).delete()
        backend.models.report.UserReport.query.filter_by(reporter_user=username).delete()

        backend.models.user.User.query.filter_by(username=username).delete()
        backend.initializers.database.DB.session.commit()
        return (
            flask.jsonify({"message": "User deleted successfully."}),
            backend.initializers.settings.HTTPStatus.NO_CONTENT.value
        )

    def get_profile(self, username: str) -> (flask.Flask, int):
        """
        Get user's profile information.

        Args:
            username (str): The username of the user.

        Returns:
            response (flask.Response): A Flask response object containing successfully deleted a user.
            status_code (int): HTTP status code indicating success (200).
        """
        user = backend.models.user.User.query.filter_by(username=username).first()
        if not user:
            return (
                flask.jsonify({"message": "User does not exist."}),
                backend.initializers.settings.HTTPStatus.NOT_FOUND.value
            )
        return flask.jsonify({"profile": user.to_dict()}), backend.initializers.settings.HTTPStatus.OK.value

    def edit_profile(self, username: str, info: dict) -> (flask.Flask, int):
        """
        Update user's profile.

        Args:
            username (str): The username of the user.
            info (dict): A dictionary containing information about the user.

        Returns:
            response (flask.Response): A Flask response object containing successfully deleted a user.
            status_code (int): HTTP status code indicating success (200).
        """
        user = backend.models.user.User.query.filter_by(username=username).first()
        user.phone_number = info.get('phone_number', user.phone_number)
        user.address = info.get('address', user.address)
        user.first_name = info.get('first_name', user.first_name)
        user.last_name = info.get('last_name', user.last_name)

        if 'image' in info:
            # Remove the previous profile picture if exists.
            old_picture = backend.models.user.ProfilePicture.query.filter_by(user_username=user.username).first()
            if old_picture:
                backend.initializers.database.DB.session.delete(old_picture)
                os.remove(f"./backend/uploads/{old_picture.filename}")
            # Save if new profile picture is uploaded.
            filename = info['image_filename']
            base, extension = os.path.splitext(filename)
            timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
            new_filename = f"{base}_{timestamp}{extension}"
            file_path = f"./backend/{flask.current_app.config['UPLOAD_FOLDER']}{new_filename}"
            info['image'].save(file_path)

            new_profile_picture = backend.models.user.ProfilePicture(
                filename=new_filename,
                user_username=username
            )
            backend.initializers.database.DB.session.add(new_profile_picture)

        backend.initializers.database.DB.session.commit()
        return flask.jsonify(
            {"message": "User edited successfully."}), backend.initializers.settings.HTTPStatus.OK.value

    def report_user(self, reporter_username: str, reported_user: str, description: str) -> (flask.Flask, int):
        """
        Report user.

        Args:
            reporter_username (str): The username of the user who reported.
            reported_user(str): The username of the reported user.
            description (str): The description of why the user was reported.

        Returns:
            response (flask.Response): A Flask response object containing successfully deleted a user.
            status_code (int): HTTP status code indicating success or bad request (200, 400).
        """
        reported_user = backend.models.user.User.query.filter_by(username=reported_user).first()
        if not reported_user:
            return (
                flask.jsonify({"message": "The reported user does not exist."}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )
        report = backend.models.report.UserReport(
            reported_user=reported_user.username,
            reporter_username=reporter_username,
            description=description
        )
        backend.initializers.database.DB.session.add(report)
        backend.initializers.database.DB.session.commit()
        return flask.jsonify(
            {"message": "User is reported successfully."}), backend.initializers.settings.HTTPStatus.OK.value
