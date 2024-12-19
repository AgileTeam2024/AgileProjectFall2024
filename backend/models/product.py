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
    CATEGORY_OPTIONS = ['Other' , 'Electronics' , 'Clothing' , 'Home & Garden' , 'Sports & Outdoors' , 'Toys & Games' , 'Automative' , 'Books & Media']


    id = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Integer,
        primary_key=True,
        autoincrement=True
    )

    product_name = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(PRODUCT_NAME_MAX_LENGTH),
        nullable=False
    )

    price = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Float,
        nullable=False
    )

    picture = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(255),
        nullable=True 
    )

    city_name = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(CITY_NAME_MAX_LENGTH),
        nullable=False
    )

    description = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String(DESCRIPTION_MAX_LENGTH),
        nullable=True 
    )

    status = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Enum(*STATUS_OPTIONS),
        default='for sale',
        nullable=False
    )

    # can be defined as a class
    category = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Enum(*CATEGORY_OPTIONS),
        default='Other',
        nullable=False
    )

        def __repr__(self) -> str:
        """
        Return a string representation of the Product instance.
        """
        return f"<Product(id={self.id}, name={self.product_name}, price={self.price}, status={self.status})>"

    # TODO : add username as foreign key
