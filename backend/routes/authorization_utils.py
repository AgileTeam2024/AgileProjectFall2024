import functools

import flask
import flask_jwt_extended

import backend.models.user
import backend.initializers.settings


def admin_required(f):
    """Checks only admins can access to admin APIs."""
    @functools.wraps(f)
    def decorated_function(*args, **kwargs):
        username = flask_jwt_extended.get_jwt_identity()
        user = backend.models.user.User.query.filter_by(username=username).first()
        if not user or not user.is_admin:
            return (
                flask.jsonify({"message": "You don't have permission to access this resource."}),
                backend.initializers.settings.HTTPStatus.FORBIDDEN.value
            )
        return f(*args, **kwargs)
    return decorated_function


def valid_user(f):
    """Checks user is not banned and must be verified."""
    @functools.wraps(f)
    def decorated_function(*args, **kwargs):
        username = flask_jwt_extended.get_jwt_identity()
        user = backend.models.user.User.query.filter_by(username=username).first()
        if user.is_banned:
            return (
                flask.jsonify({"message": "You are banned."}),
                backend.initializers.settings.HTTPStatus.FORBIDDEN.value
            )
        if not user.is_verified:
            return (
                flask.jsonify({"message": "You must verify your email."}),
                backend.initializers.settings.HTTPStatus.FORBIDDEN.value
            )
        return f(*args, **kwargs)
    return decorated_function
