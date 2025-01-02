import sqlalchemy

import backend.initializers.database


class Product(backend.initializers.database.DB.Model):
    """
        Product model representing a product in the application.
    """

    __tablename__ = 'products'

    PRODUCT_NAME_MAX_LENGTH = 50
    CITY_NAME_MAX_LENGTH = 50
    DESCRIPTION_MAX_LENGTH = 500
    STATUS_OPTIONS = ['for sale', 'sold', 'reserved']
    CATEGORY_OPTIONS = [
        'Other', 'Electronics', 'Clothing', 'Home & Garden', 'Sports & Outdoors', 'Toys & Games',
        'Automative', 'Books & Media'
    ]

    id = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Integer,
        primary_key=True,
        autoincrement=True
    )
    user_id = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Integer,
        backend.initializers.database.DB.ForeignKey('users.id'),
        nullable=False
    )
    created_at = backend.initializers.database.DB.Column(
        sqlalchemy.DateTime,
        server_default=sqlalchemy.func.now()
    )
    name = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(PRODUCT_NAME_MAX_LENGTH),
        nullable=False
    )
    price = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Float,
        nullable=False
    )
    pictures = backend.initializers.database.DB.relationship(
        'Picture',
        backref='product',
        lazy=True
    )
    city_name = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(CITY_NAME_MAX_LENGTH),
        nullable=True
    )
    description = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(DESCRIPTION_MAX_LENGTH),
        nullable=True
    )
    status = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Enum(*STATUS_OPTIONS, name='status'),
        default='for sale',
        nullable=False
    )
    # can be defined as a class
    # TODO : check doc
    category = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Enum(*CATEGORY_OPTIONS, name='category'),
        default='Other',
        nullable=False
    )

    def __repr__(self) -> str:
        """
        Return a string representation of the Product instance.
        """
        return f"<Product(id={self.id}, name={self.product_name}, price={self.price}, status={self.status})>"

    def to_dict(self) -> dict:
        """Convert the Product instance to a dictionary for JSON serialization."""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'name': self.name,
            'price': self.price,
            'pictures': [picture.filename for picture in self.pictures],  # Assuming Picture has a filename attribute
            'city_name': self.city_name,
            'description': self.description,
            'status': self.status,
            'category': self.category
        }


class Picture(backend.initializers.database.DB.Model):
    """
    Represents a product's picture.
    """
    id = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Integer,
        primary_key=True
    )
    filename = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(255),
        nullable=False
    )
    product_id = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Integer,
        backend.initializers.database.DB.ForeignKey('products.id'),
        nullable=False
    )

    def to_dict(self) -> dict:
        return {
            'id': self.id,
            'filename': self.filename
        }
