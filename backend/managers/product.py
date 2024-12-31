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
        # TODO : Check cookie
        # Check for empty fields
        if not product_name or price <= 0 or not city_name:
            return (
                flask.jsonify({'message': 'Invalid input data.'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
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

    def search_product(self, filters: dict) -> (flask.Flask, int):
        query = backend.models.product.Product.query

        # Check for name in filters and apply similarity filtering
        if 'name' in filters:
            name_filter = filters['name']
            # Using ILIKE for case-insensitive matching.
            query = query.filter(backend.models.product.Product.product_name.ilike(f'%{name_filter}%'))

        # Check for price range in filters.
        if 'min_price' in filters and 'max_price' in filters:
            min_price = filters['min_price']
            max_price = filters['max_price']
            query = query.filter(backend.models.product.Product.price.between(min_price, max_price))

        # Check for status in filters.
        if 'status' in filters:
            status_filter = filters['status']
            query = query.filter(backend.models.product.Product.status == status_filter)

        # Sort based on created_at time if asked.
        if 'sort_created_by' in filters:
            if filters['created_by'] == 'dsc':
                query = query.order_by(backend.models.product.Product.created_at.desc())
            elif filters['created_by'] == 'asc':
                query = query.order_by(backend.models.product.Product.created_at.asc())

        # Sort based on price if asked.
        if 'sort_price' in filters:
            if filters['price'] == 'dsc':
                query = query.order_by(backend.models.product.Product.price.desc())
            elif filters['price'] == 'asc':
                query = query.order_by(backend.models.product.Product.price.asc())

        # Execute the query and get results.
        products = query.all()

        return flask.jsonify({"products": products}), backend.initializers.settings.HTTPStatus.OK.value

    # TODO : Add edit and delete
