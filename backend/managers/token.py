import flask

import backend.managers.user
import backend.models.user
import backend.initializers.settings


@backend.managers.user.UserManager.instance.jwt_manager.token_in_blocklist_loader
def check_if_token_is_in_black_list(jwt_header, jwt_payload):
    """Checks whether the token is in the black list."""
    return backend.models.user.RevokedToken.query.filter_by(jti=jwt_payload["jti"]).first() is not None


@backend.managers.user.UserManager.instance.jwt_manager.revoked_token_loader
def revoked_token_callback(jwt_header, jwt_payload):
    """Callback function for revoked tokens."""
    return (
        flask.jsonify({"description": "The token has been revoked.", "error": "token_revoked"}),
        backend.initializers.settings.HTTPStatus.UNAUTHORIZED.value
    )


@backend.managers.user.UserManager.instance.jwt_manager.expired_token_loader
def my_expired_token_callback(expired_token):
    return flask.jsonify({"message": "Token is expired."}), backend.initializers.settings.HTTPStatus.UNAUTHORIZED.value
