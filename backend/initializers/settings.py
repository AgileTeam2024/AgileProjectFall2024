import enum

from absl import flags

# Database configs.
db_host = flags.DEFINE_string(
    name='db_host',
    default=None,
    help='Database host.',
    required=True,
)
db_port = flags.DEFINE_string(
    name='db_port',
    default=None,
    help='Database port.',
    required=True,
)
db_name = flags.DEFINE_string(
    name='db_name',
    default=None,
    help='Database name.',
    required=True,
)
db_username = flags.DEFINE_string(
    name='db_username',
    default=None,
    help='Database user.',
    required=True,
)
db_password = flags.DEFINE_string(
    name='db_password',
    default=None,
    help='Database password.',
    required=True,
)

# App configs.
app_host = flags.DEFINE_string(
    name='app_host',
    default='0.0.0.0',
    help='The host address on which the application will run.',
)
app_port = flags.DEFINE_integer(
    name='app_port',
    default=5000,
    help='The port on which the application will run.',
)
app_secret_key = flags.DEFINE_string(
    name='app_secret_key',
    default=None,
    help='The secret key for the application used for generating token.',
    required=True,
)


class HTTPStatus(enum.Enum):
    """
    Represents an HTTP status code.
    """
    OK = 200
    CREATED = 201
    BAD_REQUEST = 400
    UNAUTHORIZED = 401
    NOT_FOUND = 404
