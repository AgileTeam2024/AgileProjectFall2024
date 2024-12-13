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