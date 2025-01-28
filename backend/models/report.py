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
    is_resolved = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Boolean,
        nullable=False,
        default=False,
    )

    def to_dict(self):
        return {
            'id': self.id,
            'reported_user': self.reported_user,
            'reporter_username': self.reporter_username,
            'description': self.description,
            'is_resolved': self.is_resolved
        }


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
    is_resolved = backend.initializers.database.DB.Column(
        backend.initializers.database.DB.Boolean,
        nullable=False,
        default=False,
    )

    def to_dict(self):
        return {
            "id": self.id,
            "reported_product": self.reported_product,
            "reporter_username": self.reporter_username,
            "description": self.description,
            "is_resolved": self.is_resolved
        }
