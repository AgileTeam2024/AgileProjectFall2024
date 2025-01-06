import backend.initializers.database


class UserReport(backend.initializers.database.DB.Model):
    """
        UserReport model representing a report of a user.
    """
    __tablename__ = 'user_reports'

    id = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Integer,
        primary_key=True,
        autoincrement=True
    )
    reported_user = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String,
        backend.initializers.database.DB.ForeignKey('users.username'),
        nullable=False
    )
    reporter_username = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String,
        backend.initializers.database.DB.ForeignKey('users.username'),
        nullable=False
    )
    description = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String,
        nullable=False
    )


class ProductReport(backend.initializers.database.DB.Model):
    """
        ProductReport model representing a report of a product.
    """
    __tablename__ = 'product_reports'

    id = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Integer,
        primary_key=True,
        autoincrement=True
    )
    reported_product = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Integer,
        backend.initializers.database.DB.ForeignKey('products.id'),
        nullable=False
    )
    reporter_username = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String,
        backend.initializers.database.DB.ForeignKey('users.username'),
        nullable=False
    )
    description = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.String,
        nullable=False
    )
