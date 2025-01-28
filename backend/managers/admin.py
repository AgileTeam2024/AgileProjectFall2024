import flask

import backend.models.report
import backend.models.user
import backend.initializers.settings
import backend.initializers.database


class AdminManager:
    instance = None

    def __init__(self, flask_app: flask.Flask):
        if not AdminManager.instance:
            self.flask_app = flask_app
            AdminManager.instance = self

    def get_list_of_reported_products(self) -> (flask.Flask, int):
        """
        Returns the list of reported products.

        Returns:
            tuple: A tuple containing:
                - A Flask response object with a JSON message indicating success with product reports.
                - An integer representing the HTTP status code indicating success.
        """
        reported_products = backend.models.report.ProductReport.query.filter_by(is_resolved=False).all()
        return (
            flask.jsonify({"reported_products": [p.to_dict() for p in reported_products]}),
            backend.initializers.settings.HTTPStatus.OK.value
        )

    def get_banned_product_list(self) -> (flask.Flask, int):
        """
        Returns the list of banned products.

        Returns:
            tuple: A tuple containing:
                - A Flask response object with a JSON message indicating success with product reports.
                - An integer representing the HTTP status code indicating success.
        """
        banned_products = backend.models.product.Product.query.filter_by(is_banned=True).all()
        return (
            flask.jsonify({"banned_products": [p.to_dict() for p in banned_products]}),
            backend.initializers.settings.HTTPStatus.OK.value
        )

    def get_banned_user_list(self) -> (flask.Flask, int):
        """
        Returns the list of banned users.

        Returns:
            tuple: A tuple containing:
                - A Flask response object with a JSON message indicating success with product reports.
                - An integer representing the HTTP status code indicating success.
        """
        banned_users = backend.models.user.User.query.filter_by(is_banned=True).all()
        return (
            flask.jsonify({"banned_users": [p.to_dict() for p in banned_users]}),
            backend.initializers.settings.HTTPStatus.OK.value
        )

    def get_list_of_reported_users(self) -> (flask.Flask, int):
        """
        Returns the list of reported users.

        Returns:
            tuple: A tuple containing:
                - A Flask response object with a JSON message indicating success with user reports.
                - An integer representing the HTTP status code indicating success.
        """
        reported_users = backend.models.report.UserReport.query.filter_by(is_resolved=False).all()
        return (
            flask.jsonify({"reported_users": [p.to_dict() for p in reported_users]}),
            backend.initializers.settings.HTTPStatus.OK.value
        )

    def ban_user(self, username: str) -> (flask.Flask, int):
        """
        Bans a user.

        Returns:
            tuple: A tuple containing:
                - A Flask response object with a JSON message indicating success or failure.
                - An integer representing the HTTP status code (404 or 200).
        """
        # Check whether user exists.
        user = backend.models.user.User.query.filter_by(username=username).first()
        if not user:
            return (
                flask.jsonify({"message": "User not found."}),
                backend.initializers.settings.HTTPStatus.NOT_FOUND.value
            )

        for report in backend.models.report.UserReport.query.filter_by(reported_user=username).all():
            report.is_resolved = True
            backend.initializers.database.DB.session.add(report)

        # Ban user.
        user.is_banned = True
        backend.initializers.database.DB.session.add(user)
        backend.initializers.database.DB.session.commit()
        return (
            flask.jsonify({"message": "User banned successfully."}),
            backend.initializers.settings.HTTPStatus.OK.value
        )

    def ban_product(self, id: int) -> (flask.Flask, int):
        """
        Bans a product.

        Returns:
            tuple: A tuple containing:
                - A Flask response object with a JSON message indicating success or failure.
                - An integer representing the HTTP status code (404 or 200).
        """
        # Check whether user exists.
        product = backend.models.product.Product.query.filter_by(id=id).first()
        if not product:
            return (
                flask.jsonify({"message": "Product not found."}),
                backend.initializers.settings.HTTPStatus.NOT_FOUND.value
            )

        for report in backend.models.report.ProductReport.query.filter_by(reported_product=id).all():
            report.is_resolved = True
            backend.initializers.database.DB.session.add(report)

        # Ban product.
        product.is_banned = True
        backend.initializers.database.DB.session.add(product)
        backend.initializers.database.DB.session.commit()
        return (
            flask.jsonify({"message": "Product banned successfully."}),
            backend.initializers.settings.HTTPStatus.OK.value
        )

    def unban_user(self, username: str) -> (flask.Flask, int):
        """
        Unbans a user.

        Returns:
            tuple: A tuple containing:
                - A Flask response object with a JSON message indicating success or failure.
                - An integer representing the HTTP status code (404 or 200).
        """
        # Check whether user exists.
        user = backend.models.user.User.query.filter_by(username=username).first()
        if not user:
            return (
                flask.jsonify({"message": "User not found."}),
                backend.initializers.settings.HTTPStatus.NOT_FOUND.value
            )

        # Ban user.
        user.is_banned = False
        backend.initializers.database.DB.session.add(user)
        backend.initializers.database.DB.session.commit()
        return (
            flask.jsonify({"message": "User unbanned successfully."}),
            backend.initializers.settings.HTTPStatus.OK.value
        )


    def unban_product(self, product_id: int) -> (flask.Flask, int):
        """
        Unbans a product.

        Returns:
            tuple: A tuple containing:
                - A Flask response object with a JSON message indicating success or failure.
                - An integer representing the HTTP status code (404 or 200).
        """
        # Check whether user exists.
        product = backend.models.product.Product.query.filter_by(id=product_id).first()
        if not product:
            return (
                flask.jsonify({"message": "Product not found."}),
                backend.initializers.settings.HTTPStatus.NOT_FOUND.value
            )

        # Ban user.
        product.is_banned = False
        backend.initializers.database.DB.session.add(product)
        backend.initializers.database.DB.session.commit()
        return (
            flask.jsonify({"message": "Product unbanned successfully."}),
            backend.initializers.settings.HTTPStatus.OK.value
        )
