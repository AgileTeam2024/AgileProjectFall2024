import re

import flask
import flask_wtf
import wtforms

import backend.managers.product
import backend.models.product
import backend.initializers.settings

product_bp = flask.Blueprint('product', __name__)


@product_bp.route('/create', methods=['POST'])
def create() -> (flask.Flask, int):
    """
    Product Creation API.
    ---
    tags:
      - Product
    parameters:
      - name: product_name
        type: string
        required: true
        description: The name of the product.
      - name: price
        type: number
        required: true
        description: The price of the product.
      - name: city_name
        type: string
        required: true
        description: The city where the product is located.
      - name: description
        type: string
        required: false
        description: A description of the product (optional).
      - name: category
        type: string
        required: false
        description: The category of the product (default is 'Other').
    responses:
      201:
        description: Product created successfully.
      400:
        description: Invalid input data.
      500:
        description: Internal server error.
    
    """
    query_params = flask.request.args.to_dict()

    product_name = query_params.get('product_name', '')
    if not product_name:
        return (
            flask.jsonify({'message': 'Product name cannot be empty.'}),
            backend.initializers.setting.HTTPStatus.BAD_REQUEST.value
        )
    price = query_params.get('price', type=float)
    if price is None or not isinstance(price, (int, float)) or price <= 0:
        return (
            flask.jsonify({'message': 'Please enter price value correctly.'}),
            HTTPStatus.BAD_REQUEST.value
        )
    # TODO : city name can be optional
    city_name = query_params.get('city_name')
    if not city_name:
        return (
            flask.jsonify({'message': 'City name cannot be empty.'}),
            backend.initializers.setting.HTTPStatus.BAD_REQUEST.value
        )
    description = query_params.get('description')
    category = query_params.get('category', default='Other')
    # TODO : check for valid category
    return backend.managers.product.ProductManager.instance.create_product(product_name, price, city_name, description,
                                                                           category)


@product_bp.route('/search', methods=['POST'])
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
      - name: sort_created_by
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
