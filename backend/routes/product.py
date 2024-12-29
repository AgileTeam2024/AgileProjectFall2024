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
    city_name = query_params.get('city_name')
    if not city_name:
        return (
            flask.jsonify({'message': 'City name cannot be empty.'}),
            backend.initializers.setting.HTTPStatus.BAD_REQUEST.value
        )
    description = query_params.get('description')
    category = query_params.get('category', default='Other')
    # TODO : check for valid category
    return backend.managers.product.ProductManager.instance.create_product(product_name, price, city_name, description, category)


