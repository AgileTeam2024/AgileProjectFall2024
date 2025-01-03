import flask

import backend.models.product
import backend.initializers.database
import backend.initializers.settings


class ProductManager:
    instance = None

    def __init__(self, flask_app: flask.Flask):
        if not ProductManager.instance:
            self.flask_app = flask_app
            ProductManager.instance = self

    def create_product(self, product_data: dict) -> (flask.Flask, int):
        """
        Create a new product in the database.

        Args:
            product_data (dict): A dictionary containing product details such as name, description,
                                 price, user username, status, category, city name, and pictures.

        Returns:
            tuple: A tuple containing a JSON response and an HTTP status code.
        """

        # Create a new Product instance using the provided product data.
        new_product = backend.models.product.Product(
            name=product_data['name'],
            description=product_data['description'],
            price=product_data['price'],
            user_username=product_data['user_username'],
            status=product_data['status'],
            category=product_data['category'],
            city_name=product_data.get('city_name', ''),
        )
        backend.initializers.database.DB.session.add(new_product)

        # Iterate over the list of pictures to save each one.
        for file, file_path in zip(product_data['images'], product_data['images_path']):
            file.save(file_path)
            # Create a new Picture instance associated with the newly created product.
            new_picture = backend.models.product.Picture(
                filename=file_path,
                product_id=new_product.id,
            )
            backend.initializers.database.DB.session.add(new_picture)

        backend.initializers.database.DB.session.commit()
        return (
            flask.jsonify({"message": "Product created successfully."}),
            backend.initializers.settings.HTTPStatus.CREATED.value
        )

    def search_product(self, filters: dict) -> (flask.Flask, int):
        """
        Search for products based on various filters.

        This method constructs a query to search for products in the database
        based on the provided filters. It supports filtering by name, price range,
        status, and sorting by creation date or price. The results are returned
        in JSON format along with a 200 OK status code.

        Args:
            filters (dict): A dictionary containing filter criteria for the search.
                - 'name' (str): A substring to search for in product names.
                - 'min_price' (float): Minimum price for filtering products.
                - 'max_price' (float): Maximum price for filtering products.
                - 'status' (str): Status of the product (e.g., 'for sale', 'sold').
                - 'sort_created_at' (str): Sorting order for creation date ('asc' or 'dsc').
                - 'sort_price' (str): Sorting order for price ('asc' or 'dsc').

        Returns:
            tuple: A tuple containing:
                - A Flask response object containing the JSON representation of the products.
                - An integer representing the HTTP status code (200 for success).
        """
        query = backend.models.product.Product.query

        # Check for name in filters and apply similarity filtering
        if 'name' in filters:
            name_filter = filters['name']
            # Using ILIKE for case-insensitive matching.
            query = query.filter(backend.models.product.Product.name.ilike(f'%{name_filter}%'))

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
        if 'sort_created_at' in filters:
            if filters['sort_created_at'] == 'dsc':
                query = query.order_by(backend.models.product.Product.created_at.desc())
            elif filters['sort_created_at'] == 'asc':
                query = query.order_by(backend.models.product.Product.created_at.asc())

        # Sort based on price if asked.
        if 'sort_price' in filters:
            if filters['sort_price'] == 'dsc':
                query = query.order_by(backend.models.product.Product.price.desc())
            elif filters['sort_price'] == 'asc':
                query = query.order_by(backend.models.product.Product.price.asc())

        # Execute the query and get results.
        products = query.all()
        products_as_dicts = [product.to_dict() for product in products]

        return flask.jsonify({"products": products_as_dicts}), backend.initializers.settings.HTTPStatus.OK.value

    # TODO : Add edit and delete

    def get_product(self, product_id: int) -> (flask.Flask, int):
        """
        Retrieve a product by its ID.

        This method queries the database for a product with the specified ID.
        If a product is found, it returns the product details in JSON format
        along with a 200 OK status code. If no product is found, it returns
        a message indicating that no product was found along with a 404 Not Found status code.

        Args:
            product_id (int): The ID of the product to retrieve.

        Returns:
            tuple: A tuple containing:
                - A Flask response object containing the JSON representation of the product or an error message.
                - An integer representing the HTTP status code (200 for success, 404 if not found).
        """
        product = backend.models.product.Product.query.get(product_id)
        if not product:
            return (
                flask.jsonify({'message': 'No product found with the provided ID.'}),
                backend.initializers.settings.HTTPStatus.NOT_FOUND.value
            )
        return flask.jsonify({"product": product.to_dict()}), backend.initializers.settings.HTTPStatus.OK.value
