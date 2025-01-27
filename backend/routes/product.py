import flask
import flask_jwt_extended
import werkzeug.utils

import backend.managers.product
import backend.models.product
import backend.initializers.settings
import backend.routes.authorization_utils

product_bp = flask.Blueprint('product', __name__)


@product_bp.route('/create', methods=['POST'])
@flask_jwt_extended.jwt_required()
@backend.routes.authorization_utils.valid_user
def create() -> (flask.Flask, int):
    """
    Create a new product.
    ---
    components:
      securitySchemes:
        BearerAuth:
          type: http
          scheme: bearer
          bearerFormat: JWT
    tags:
      - Product
    security:
      - BearerAuth: []
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
          - Others
          - Real-Estate
          - Automobile
          - Digital & Electronics
          - Kitchenware
          - Entertainment
          - Personal Items
        description: The category of the product.
      - name: pictures
        in: formData
        type: file
        required: true
        allowMultiple: true
        collectionFormat: multi
        description: Images of the product. You can upload multiple images.
    responses:
      201:
        description: Product created successfully.
      400:
        description: Bad Request if any required fields are missing or invalid.
    """

    user_username = flask_jwt_extended.get_jwt_identity()
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
    if category not in backend.models.product.Product.CATEGORY_OPTIONS:
        return (
            flask.jsonify({'message': 'Invalid value for category.'}),
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
            images.append(image_file)
            images_path.append(filename)

    product_data = {
        'name': name,
        'price': price,
        'city_name': city_name,
        'status': status,
        'category': category,
        'user_username': user_username,
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
        description: Status of the product.
      - name: category
        in: query
        type: string
        required: false
        enum:
          - Others
          - Real-Estate
          - Automobile
          - Digital & Electronics
          - Kitchenware
          - Entertainment
          - Personal Items
        description: Status of the product.
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

    # Retrieve and validate the 'category' filter from query parameters.
    filter_category = flask.request.args.get('category')
    if filter_category:
        if filter_category not in backend.models.product.Product.CATEGORY_OPTIONS:
            return (
                flask.jsonify({'message': 'Invalid value for filter category.'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )
        filters['category'] = filter_category

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
    filter_sort_created_at = flask.request.args.get('sort_created_at')
    if filter_sort_created_at:
        if filter_sort_created_at != 'dsc' and filter_sort_created_at != 'asc':
            return (
                flask.jsonify({'message': 'Sort type of created at must be either asc or dsc.'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )
        filters['sort_created_at'] = filter_sort_created_at

    # Check for sorting options for 'price'
    filter_sort_price = flask.request.args.get('sort_price')
    if filter_sort_price:
        if filter_sort_price != 'dsc' and filter_sort_price != 'asc':
            return (
                flask.jsonify({'message': 'Sort type of price must be either asc or dsc.'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )
        filters['sort_price'] = filter_sort_price

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

    return backend.managers.product.ProductManager.instance.get_product(product_id)


@product_bp.route('/delete', methods=['DELETE'])
@flask_jwt_extended.jwt_required()
@backend.routes.authorization_utils.valid_user
def delete_product() -> (flask.Flask, int):
    """
    Product delete API.
    ---
    tags:
      - Product
    security:
      - BearerAuth: []
    parameters:
      - name: product_id
        in: query
        type: integer
        required: true
        description: The ID of the product to delete.
    responses:
      200:
        description: successful delete
      400:
        description: bad request
      401:
        description: unauthorized user access
      404:
        description: product with this id doesn't exist.
    """
    user_username = flask_jwt_extended.get_jwt_identity()
    product_id = flask.request.args.get('product_id')
    if not product_id:
        return (
            flask.jsonify({'message': 'Missing product ID.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    if not product_id.isdigit():
        return (
            flask.jsonify({'message': 'Product ID must be an integer.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )

    return backend.managers.product.ProductManager.instance.delete_product(user_username, product_id)


@product_bp.route('/edit_product', methods=['PUT'])
@flask_jwt_extended.jwt_required()
@backend.routes.authorization_utils.valid_user
def edit_product() -> (flask.Flask, int):
    """
    Edit product's properties.
    ---
    tags:
      - Product
    security:
      - BearerAuth: []
    parameters:
      - name: product_id
        in: query
        type: integer
        required: true
        description: The ID of the product to edit.
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
          - Others
          - Digital & Electronics
          - Automobile
          - Kitchenware
          - Real-Estate
          - Personal Items
          - Entertainment
        description: The category of the product.
      - name: pictures
        in: formData
        type: file
        required: true
        allowMultiple: true
        collectionFormat: multi
        description: Images of the product. You can upload multiple images.
    responses:
      200:
        description: Product edited successfully.
      400:
        description: Bad Request if any required fields are missing or invalid.
      401:
        description: This user cannot edit this product.
      404:
        description: Not found if the product with the provided id doesn't exist.
    """
    user_username = flask_jwt_extended.get_jwt_identity()
    data = {}
    product_id = flask.request.form.get('product_id')
    if not product_id:
        return (
            flask.jsonify({'message': 'Product id is required'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    product_name = flask.request.form.get('name')
    if product_name:
        data['name'] = product_name
    product_price = flask.request.form.get('price')
    if product_price:
        try:
            price = float(product_price)
            data['price'] = price
        except ValueError:
            return (
                flask.jsonify({'message': 'Price must be a valid float number.'}),
                backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
            )
    product_city = flask.request.form.get('city_name')
    if product_city:
        data['city_name'] = product_city
    product_description = flask.request.form.get('description')
    if product_description:
        data['description'] = product_description
    product_status = flask.request.form.get('status')
    if product_status:
        data['status'] = product_status
    product_category = flask.request.form.get('category')
    if product_category:
        data['category'] = product_category

    image_files = flask.request.files.getlist('picture')
    images = []
    images_path = []
    # Validate files and create path for storing them.
    for image_file in image_files:
        if (image_file and '.' in image_file.filename and
                image_file.filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg', 'gif'}):
            filename = werkzeug.utils.secure_filename(image_file.filename)
            images.append(image_file)
            images_path.append(filename)
    data['images'] = images
    data['images_path'] = images_path
    data['user_username'] = user_username

    return backend.managers.product.ProductManager.instance.edit_product(user_username, product_id, data)


@product_bp.route('/report_product', methods=['POST'])
@flask_jwt_extended.jwt_required()
@backend.routes.authorization_utils.valid_user
def report_product() -> (flask.Flask, int):
    """
    Report a product for inappropriate content.
    ---
    tags:
      - Product
    security:
      - BearerAuth: []
    parameters:
      - name: reported_product
        in: formData
        type: integer
        required: true
        description: The ID of the product being reported.
      - name: description
        in: formData
        type: string
        required: true
        description: A description of the reason for reporting the user.
    responses:
      200:
        description: Product is reported successfully.
      400:
        description: Bad request. Missing required fields.
    """
    reporter_username = flask_jwt_extended.get_jwt_identity()
    reported_product = flask.request.form.get('reported_product')
    if not reported_product:
        return (
            flask.jsonify({'message': 'Missing reported product.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    if not reported_product.isdigit():
        return (
            flask.jsonify({'message': 'Reported product must be a number.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    reported_product = int(reported_product)
    description = flask.request.form.get('description')
    if not description:
        return (
            flask.jsonify({'message': 'Missing description.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    return backend.managers.product.ProductManager.instance.report_product(reporter_username, reported_product,
                                                                           description)


@product_bp.route('/product_list', methods=['GET'])
@flask_jwt_extended.jwt_required()
def get_products() -> (flask.Flask, int):
    """
    API for returning a list of products that are on sale for a user.
    ---
    tags:
      - product
    security:
      - BearerAuth: []
    responses:
      200:
        description: Products are returned successfully.
    """
    username = flask_jwt_extended.get_jwt_identity()
    return backend.managers.product.ProductManager.instance.get_products(username)


@product_bp.route('/ban_product', methods=['PUT'])
@flask_jwt_extended.jwt_required()
def ban_product() -> (flask.Flask, int):
    """
    Product ban API.
    ---
    tags:
      - product
    security:
      - BearerAuth: []
    parameters:
    - name: product_id
      in: query
      type: integer
      required: true
      description: The ID of the product to ban.
    responses:
      200:
        description: Product is banned successfully.
      401:
        description: User must be admin.
      404:
        description: No products found with this id.
    """
    product_id = flask.request.args.get('product_id')
    # Check if product ID is missing
    if not product_id:
        return (
            flask.jsonify({'message': 'Missing product ID.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    if not product_id.isdigit():
        return (
            flask.jsonify({'message': 'Product ID must be an integer.'}),
            backend.initializers.settings.HTTPStatus.BAD_REQUEST.value
        )
    return backend.managers.product.ProductManager.instance.ban_product(product_id)
