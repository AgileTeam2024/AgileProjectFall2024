import flask
import flask_jwt_extended

import backend.models.user
import backend.initializers.settings
import backend.managers.admin
import backend.routes.authorization_utils

admin_bp = flask.Blueprint('admin', __name__)


@admin_bp.route('/user-reports-list', methods=['GET'])
@flask_jwt_extended.jwt_required()
@backend.routes.authorization_utils.admin_required
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
@backend.routes.authorization_utils.admin_required
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
@backend.routes.authorization_utils.admin_required
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
      400:
        description: Username is missing.
      403:
        description: Only admins have access to this API.
      404:
        description: User not found.
    """
    username = flask.request.form.get('username')
    if not username:
        return (
            flask.jsonify({"message": "Username is missing."}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    return backend.managers.admin.AdminManager.instance.ban_user(username)


@admin_bp.route('/ban_product', methods=['POST'])
@flask_jwt_extended.jwt_required()
@backend.routes.authorization_utils.admin_required
def ban_product():
    """
    Admin Ban User.
    ---
    tags:
      - Admin
    security:
      - BearerAuth: []
    parameters:
      - name: product_id
        in: formData
        required: true
        type: string
        description: The ID of the product you want to ban.
    responses:
      200:
        description: Successfully banned the product.
      400:
        description: product_id is missing.
      403:
        description: Only admins have access to this API.
      404:
        description: Product not found.
    """
    product_id = flask.request.form.get('product_id')
    if not product_id:
        return (
            flask.jsonify({"message": "product_id is missing."}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    return backend.managers.admin.AdminManager.instance.ban_product(product_id)


@admin_bp.route('/ban_user', methods=['POST'])
@flask_jwt_extended.jwt_required()
@backend.routes.authorization_utils.admin_required
def unban_user():
    """
    Admin Unban User.
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
        description: The username you want to unban.
    responses:
      200:
        description: Successfully unbanned the user.
      400:
        description: Username is missing.
      403:
        description: Only admins have access to this API.
    """
    username = flask.request.form.get('username')
    if not username:
        return (
            flask.jsonify({"message": "Username is missing."}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    return backend.managers.admin.AdminManager.instance.unban_user(username)
