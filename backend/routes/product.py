import os

import flask
import flask_jwt_extended
import werkzeug.utils

import backend.managers.product
import backend.models.product
import backend.initializers.settings

product_bp = flask.Blueprint('product', __name__)


@product_bp.route('/create', methods=['POST'])
def create() -> (flask.Flask, int):
    """
    Create a new product.
    ---
    tags:
      - Product
    parameters:
      - name: name
        in: formData
        required: true
        type: string
        description: The name of the product.
      - name: price
        in: formData
        required: true
        type: number
        format: float
        description: The price of the product.
      - name: city_name
        in: formData
        required: false
        type: string
        description: The city where the product is located.
      - name: description
        in: formData
        required: true
        type: string
        description: Description about the product.
      - name: status
        in: formData
        required: true
        type: string
        enum:
          - reserved
          - sold
          - for sale
        description: The status of the product.
      - name: category
        in: formData
        required: true
        type: string
        enum:
          - Other
          - Electronics
          - Clothing
          - Home & Garden
          - Sports & Outdoors
          - Toys & Games
          - Automotive  # Corrected spelling from "Automative"
          - Books & Media
        description: The category of the product.
      - name: pictures
        in: formData
        required: false
        type: array  # Note that this should be handled as a file upload in Swagger.
        items:
          type: string
          format: binary  # Indicate that these are file uploads.
        description: Images of the product. You can upload multiple images.
    responses:
      '201':
        description: Product created successfully.
      '400':
        description: Bad Request if any required fields are missing or invalid.
    """

    # user_username = flask_jwt_extended.get_jwt_identity()
    # Validate product name exists.
    name = flask.request.form.get('name')
    if not name:
        return (
            flask.jsonify({'message': 'Missing product name.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    # Validate price exists and it is a valid float number.
    price = flask.request.form.get('price')
    if not price:
        return (
            flask.jsonify({'message': 'Missing price.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    try:
        price = float(price)
    except ValueError:
        return (
            flask.jsonify({'message': 'Price must be a valid float number.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    city_name = flask.request.form.get('city_name')
    description = flask.request.form.get('description')
    if not description:
        return (
            flask.jsonify({'message': 'Missing description.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    # Validate status exists and has a value in defined status enum.
    status = flask.request.form.get('status')
    if not status:
        return (
            flask.jsonify({'message': 'Missing status.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    if status not in backend.models.product.Product.STATUS_OPTIONS:
        return (
            flask.jsonify({'message': 'Invalid value for status.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    # Validate category exists and has a value in defined category enum.
    category = flask.request.form.get('category')
    if not category:
        return (
            flask.jsonify({'message': 'Missing status.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )

    # Get list of files from the 'pictures' field
    image_files = flask.request.files.getlist('pictures')
    images = []
    images_path = []
    # Validate files and create path for storing them.
    for image_file in image_files:
        if (image_file and '.' in image_file.filename and
                image_file.filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg', 'gif'}):
            filename = werkzeug.utils.secure_filename(image_file.filename)
            image_path = os.path.join(flask.current_app.config['UPLOAD_FOLDER'], filename)
            images.append(image_file)
            images_path.append(image_path)

    product_data = {
        'name': name,
        'price': price,
        'city_name': city_name,
        'status': status,
        'category': category,
        'user_username': 'farhad',
        'images': images,
        'images_path': images_path,
        'description': description
    }
    return backend.managers.product.ProductManager.instance.create_product(product_data)


@product_bp.route('/search', methods=['GET'])
def search() -> (flask.Flask, int):
    """
    Search for products based on various filters.
    ---
    tags:
      - Product
    parameters:
      - name: name
        in: query
        type: string
        required: false
        description: Name of the product to filter by (case-insensitive).
      - name: min_price
        in: query
        type: number
        required: false
        description: Minimum price of the product.
      - name: max_price
        in: query
        type: number
        required: false
        description: Maximum price of the product.
      - name: status
        in: query
        type: string
        required: false
        enum:
        - for sale
        - reserved
        - sold
        description: Status of the product (e.g., available, out_of_stock).
      - name: sort_created_at
        in: query
        type: string
        required: false
        enum:
          - asc
          - dsc
        description: Sort order for creation date. Use 'asc' for ascending and 'dsc' for descending.
      - name: sort_price
        in: query
        type: string
        required: false
        enum:
          - asc
          - dsc
        description: Sort order for price. Use 'asc' for ascending and 'dsc' for descending.
    responses:
      200:
        description: A list of products matching the filters.
        schema:
          type: object
          properties:
            products:
              type: array
      400:
        description: Bad request if filters are invalid.
      200:
        description: Products filtered successfully.
    """
    filters = {}

    # Retrieve the 'name' filter from query parameters.
    filter_name = flask.request.args.get('name')
    if filter_name:
        filters['name'] = filter_name

    # Retrieve and validate the 'status' filter from query parameters.
    filter_status = flask.request.args.get('status')
    if filter_status:
        if filter_status not in backend.models.product.Product.STATUS_OPTIONS:
            return (
                flask.jsonify({'message': 'Invalid value for filter status.'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )
        filters['status'] = filter_status

    # Retrieve price range filters from query parameters.
    filter_min_price = flask.request.args.get('min_price')
    filter_max_price = flask.request.args.get('max_price')
    # Validate that both min_price and max_price are provided together.
    if (not filter_min_price and filter_max_price) or (not filter_max_price and filter_min_price):
        return (
            flask.jsonify({'message': 'Min price and max price must both be provided.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )

    # Validate and convert price filters to integers if both are provided.
    if filter_min_price and filter_max_price:
        if not filter_min_price.isdigit():
            return (
                flask.jsonify({'message': 'Min price must be an integer.'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )
        if not filter_max_price.isdigit():
            return (
                flask.jsonify({'message': 'Max price must be an integer.'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )
        filters['min_price'] = int(filter_min_price)
        filters['max_price'] = int(filter_max_price)

    # Check for sorting options for 'created_at'.
    if 'sort_created_at' in filters:
        if filters['sort_created_at'] != 'desc' and filters['sort_created_at'] != 'asc':
            return (
                flask.jsonify({'message': 'Sort type of created at must be either asc or desc.'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )
        filters['sort_created_at'] = flask.request.args.get('sort_created_at')

    # Check for sorting options for 'price'
    if 'sort_price' in filters:
        if filters['sort_price'] != 'desc' and filters['sort_price'] != 'asc':
            return (
                flask.jsonify({'message': 'Sort type of price must be either asc or desc.'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )
        filters['sort_price'] = filters['sort_price']

    return backend.managers.product.ProductManager.instance.search_product(filters)


@product_bp.route('/get_product_by_id', methods=['GET'])
def get_product_by_id():
    """
    Retrieve a product by its ID.
    ---
    tags:
      - Product
    parameters:
      - name: product_id
        in: query
        type: integer
        required: true
        description: The ID of the product to retrieve.
    responses:
      200:
        description: Product details retrieved successfully.
      404:
        description: No product found with the provided ID.
      400:
        description: Invalid input, product ID must be an integer.
    """
    product_id = flask.request.args.get('product_id')
    # Check if product ID is missing
    if not product_id:
        return (
            flask.jsonify({'message': 'Missing product ID.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    # Check if product ID is a valid integer.
    if not product_id.isdigit():
        return (
            flask.jsonify({'message': 'Product ID must be an integer.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )

    return backend.managers.product.ProductManager.instance.get_product_by_id(product_id)
