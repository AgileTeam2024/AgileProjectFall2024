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

# Verification email configs.
mail_server_host = flags.DEFINE_string(
    name='mail_server_host',
    default='smtp.mail.yahoo.com',
    help='The mail server address.',
)

mail_server_port = flags.DEFINE_integer(
    name='mail_server_port',
    default=587,
    help='The mail server port.',
)
mail_sender_email = flags.DEFINE_string(
    name='mail_sender_email',
    default=None,
    help='The mail sender.',
    required=True,
)
mail_sender_password = flags.DEFINE_string(
    name='mail_sender_password',
    default=None,
    help='The mail sender password.',
    required=True,
)


class HTTPStatus(enum.Enum):
    """
    Represents an HTTP status code.
    """
    OK = 200
    CREATED = 201
    NO_CONTENT = 204
    BAD_REQUEST = 400
    UNAUTHORIZED = 401
    FORBIDDEN = 403
    NOT_FOUND = 404


# The directory which all databased changes are stored at.
MIGRATIONS_DIRECTORY = 'backend/migrations'
