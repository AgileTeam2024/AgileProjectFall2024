import functools

import flask
import flask_jwt_extended

import backend.models.user
import backend.initializers.settings
import backend.managers.admin

admin_bp = flask.Blueprint('admin', __name__)


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


@admin_bp.route('/user-reports-list', methods=['GET'])
@flask_jwt_extended.jwt_required()
@admin_required
def get_user_reports_list():
    """
    Admin Get User Reports List.
    ---
    tags:
      - Admin
    security:
      - BearerAuth: []
    responses:
      200:
        description: Successfully returned user reports list.
      403:
        description: Only admins have access to this API.
    """
    return backend.managers.admin.AdminManager.instance.get_list_of_reported_users()


@admin_bp.route('/product-reports-list', methods=['GET'])
@flask_jwt_extended.jwt_required()
@admin_required
def get_product_reports_list():
    """
    Admin Get Product Reports List.
    ---
    tags:
      - Admin
    security:
      - BearerAuth: []
    responses:
      200:
        description: Successfully returned product reports list.
      403:
        description: Only admins have access to this API.
    """
    return backend.managers.admin.AdminManager.instance.get_list_of_reported_products()


@admin_bp.route('/ban_user', methods=['POST'])
@flask_jwt_extended.jwt_required()
@admin_required
def ban_user():
    """
    Admin Ban User.
    ---
    tags:
      - Admin
    security:
      - BearerAuth: []
    parameters:
      - name: username
        in: formData
        required: true
        type: string
        description: The username you want to ban.
    responses:
      200:
        description: Successfully banned the user.
      403:
        description: Only admins have access to this API.
    """
    username = flask.request.form.get('username')
    return backend.managers.admin.AdminManager.instance.ban_user(username)
