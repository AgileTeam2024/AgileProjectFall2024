import os
import datetime

import flask

import backend.models.product
import backend.initializers.database
import backend.initializers.settings
import backend.models.user
import backend.models.report
import flask_jwt_extended


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
        backend.initializers.database.DB.session.commit()

        # Iterate over the list of pictures to save each one.
        for file, filename in zip(product_data['images'], product_data['images_path']):
            # Generate a new filename by appending a timestamp to avoid duplicate name.
            base, extension = os.path.splitext(filename)
            timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
            new_filename = f"{base}_{timestamp}{extension}"
            file_path = f"./backend/{flask.current_app.config['UPLOAD_FOLDER']}{new_filename}"
            file.save(file_path)
            # Create a new Picture instance associated with the newly created product.
            new_picture = backend.models.product.Picture(
                filename=new_filename,
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
                - 'status' (str): Status of the product.
                - 'category' (str): Category of the product (e.g., 'for sale', 'sold').
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

        # Check for category in filters.
        if 'category' in filters:
            category_filter = filters['category']
            query = query.filter(backend.models.product.Product.category == category_filter)

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
        products_as_dicts = [product.to_dict() for product in products if not product.is_banned]

        return flask.jsonify({"products": products_as_dicts}), backend.initializers.settings.HTTPStatus.OK.value

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
        product_dict = product.to_dict()
        if product.user_username:
            seller = backend.models.user.User.query.get(product.user_username).to_dict()
            product_dict['seller'] = seller
        return flask.jsonify({"product": product_dict}), backend.initializers.settings.HTTPStatus.OK.value

    def delete_product(self, username: str, product_id: int) -> (flask.Flask, int):
        """
        Deletes a product.

        Args:
            product_id (Integer): The id of the product to be deleted.
            username (str): The username of the current user.
        Returns:
            response (flask.Response): A Flask response object containing successfully deleted a user.
            status_code (int): HTTP status code indicating successful delete (204).
        """
        product = backend.models.product.Product.query.filter_by(id=product_id).first()
        if not product:
            return (
                flask.jsonify({'message': 'Product does not exist.'}),
                backend.initializers.settings.HTTPStatus.NOT_FOUND.value
            )
        if product.user_username != username:
            return (
                flask.jsonify({'message': 'You do not have access to edit this product.'}),
                backend.initializers.settings.HTTPStatus.UNAUTHORIZED.value
            )
        product_pictures = backend.models.product.Picture.query.filter_by(product_id=product_id).all()
        for picture in product_pictures:
            backend.initializers.database.DB.session.delete(picture)
            os.remove(picture.filename)
        product = backend.models.product.Product.query.filter_by(id=product_id)
        backend.initializers.database.DB.session.delete(product)
        backend.initializers.database.DB.session.commit()
        return (
            flask.jsonify({"message": "Product deleted successfully."}),
            backend.initializers.settings.HTTPStatus.NO_CONTENT.value
        )

    def edit_product(self, username: str, product_id: int, product_data: dict) -> (flask.Flask, int):
        """
        Edit product's properties.

        Args:
            username (str): The username of the current user.
            product_id (int): The id of the product.
            product_data (dict): A dictionary containing the updated info of the product.
        Returns:
            response (flask.Response): A Flask response object containing successfully editing a product.
            status_code (int): HTTP status code indicating success (200).
        """

        product = backend.models.product.Product.query.filter_by(id=product_id).first()
        if not product:
            return (
                flask.jsonify({'message': 'Product does not exist.'}),
                backend.initializers.settings.HTTPStatus.NOT_FOUND.value
            )
        if product.user_username != username:
            return (
                flask.jsonify({'message': 'You do not have access to edit this product.'}),
                backend.initializers.settings.HTTPStatus.UNAUTHORIZED.value
            )
        product.name = product_data.get('name', product.name)
        product.price = product_data.get('price', product.price)
        product.city_name = product_data.get('city_name', product.city_name)
        product.description = product_data.get('description', product.description)
        product.status = product_data.get('status', product.status)
        product.category = product_data.get('category', product.category)
        product.user_username = product_data.get('user_username', product.user_username)

        # Deleting old pictures
        product_pictures = backend.models.product.Picture.query.filter_by(id=product.id).all()
        for picture in product_pictures:
            backend.initializers.database.DB.session.delete(picture)
            os.remove(picture.filename)

        # Adding new pictures
        if 'images' in product_data.keys():
            for file, filename in zip(product_data['images'], product_data['images_path']):
                # Generate a new filename by appending a timestamp to avoid duplicate name.
                base, extension = os.path.splitext(filename)
                timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
                new_filename = f"{base}_{timestamp}{extension}"
                file_path = f"./backend/{flask.current_app.config['UPLOAD_FOLDER']}{new_filename}"
                file.save(file_path)
                # Create a new Picture instance associated with the newly created product.
                new_picture = backend.models.product.Picture(
                    filename=new_filename,
                    product_id=product_id,
                )
                backend.initializers.database.DB.session.add(new_picture)

        backend.initializers.database.DB.session.commit()

        return flask.jsonify({"message": "Product edited successfully."}), backend.initializers.settings.HTTPStatus.OK.value

    def report_product(self, reporter_username: str, reported_product: int, description: str) -> (flask.Flask, int):
        """
        Report product.

        Args:
            reporter_username: (str): The username of the user who reported.
            reported_product(str): The ID of the reported product.
            description (str): The description of why the user was reported.

        Returns:
            response (flask.Response): A Flask response object containing successfully deleted a user.
            status_code (int): HTTP status code indicating success (200).
        """
        reported_product = backend.models.product.Product.query.filter_by(id=reported_product).first()
        if not reported_product:
            return (
                flask.jsonify({"message": "The reported product does not exist."}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )
        report = backend.models.report.ProductReport(
            reported_product=reported_product.id,
            reporter_username=reporter_username,
            description=description
        )
        backend.initializers.database.DB.session.add(report)
        backend.initializers.database.DB.session.commit()
        return flask.jsonify(
            {"message": "Product is reported successfully."}), backend.initializers.settings.HTTPStatus.OK.value

    def get_products(self, user_username: str) -> (flask.Flask, int):
        """
        Returns a list of products belonging to a user that are on sale.

        Args:
            user_username (str): username of the user
        Returns:
            response (flask.Response): A Flask response object containing successfully returning a list.
            status_code (int):
                200: successful search
        """
        products = backend.models.product.Product.query.filter_by(
            user_username=user_username,
        ).all()
        products_as_dicts = [product.to_dict() for product in products]
        return flask.jsonify({"products": products_as_dicts}), backend.initializers.settings.HTTPStatus.OK.value
