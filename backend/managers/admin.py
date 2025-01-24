import flask

import backend.models.report
import backend.initializers.settings


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
        reported_products = backend.models.report.ProductReport.query.all()
        return (
            flask.jsonify({"reported_products": [p.to_dict() for p in reported_products]}),
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
        reported_users = backend.models.report.UserReport.query.all()
        return (
            flask.jsonify({"reported_users": [p.to_dict() for p in reported_users]}),
            backend.initializers.settings.HTTPStatus.OK.value
        )
