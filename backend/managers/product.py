import flask
import flask_jwt_extended

import backend.models.product
import backend.initializers.database
import backend.initializers.settings

class ProductManager:
    instance = None

    def __init__(self, flask_app: flask.Flask):
        if not ProductManager.instance:
            self.flask_app = flask_app
            ProductManager.instance = self


    def create_product(self, product_name: str, price: float, city_name: str, description: str = None, category: str = 'Other') -> (flask.Flask, int):
        """
        Creates a new product with the provided details.

        Args:
            product_name (str): The name of the product.
            price (float): The price of the product.
            city_name (str): The city where the product is located.
            description (str): A description of the product (optional).
            category (str): The category of the product (default is 'Other').

        Returns:
                - A Flask response object with a JSON message indicating success or failure.
                - An integer representing the HTTP status code (e.g., 201 for created, 400 for bad request).

        """
        # Check for empty fields
        if not product_name or price <= 0 or not city_name:
            return (
                flask.jsonify({'message': 'Invalid input data.'}),
                backend.initia;izers.setting.HTTPStatus.BAD_REQUEST.value
            )

        # Create product instance
        new_product = backend.models.product.Product(
            product_name=product_name,
            price=price,
            city_name=city_name,
            description=description
        )

        # Adding the new product to the database
        backend.initializers.database.DB.session.add(new_product)
        backend.initializers.database.DB.session.commit()

        return (
            flask.jsonify({"message": "Product created successfully."}),
            backend.initializers.settings.HTTPStatus.CREATED.value
        )


    # TODO : Add edit and delete