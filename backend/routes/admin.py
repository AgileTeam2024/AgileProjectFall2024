import flask
import flask_jwt_extended

import backend.models.user
import backend.initializers.settings
import backend.managers.admin

admin_bp = flask.Blueprint('admin', __name__)


@admin_bp.route('/user-reports-list', methods=['GET'])
@flask_jwt_extended.jwt_required()
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
    username = flask_jwt_extended.get_jwt_identity()
    user = backend.models.user.User.query.filter_by(username=username).first()
    if not user.is_admin:
        return (
            flask.jsonify({"message": "You don't have permission to access this resource."}),
            backend.initializers.settings.HTTPStatus.FORBIDDEN.value
        )
    return backend.managers.admin.AdminManager.instance.get_list_of_reported_users()


@admin_bp.route('/product-reports-list', methods=['GET'])
@flask_jwt_extended.jwt_required()
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
    username = flask_jwt_extended.get_jwt_identity()
    user = backend.models.user.User.query.filter_by(username=username).first()
    if not user.is_admin:
        return (
            flask.jsonify({"message": "You don't have permission to access this resource."}),
            backend.initializers.settings.HTTPStatus.FORBIDDEN.value
        )
    return backend.managers.admin.AdminManager.instance.get_list_of_reported_products()
