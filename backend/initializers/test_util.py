from absl import flags

import backend.initializers.settings


def pass_flags_as_parsed() -> None:
    """Set required flags to suppress unit-test's flag parse error."""
    flags.FLAGS.__setattr__(backend.initializers.settings.db_username.name, "db_username")
    flags.FLAGS.__setattr__(backend.initializers.settings.db_password.name, "db_password")
    flags.FLAGS.__setattr__(backend.initializers.settings.db_name.name, "db_name")
    flags.FLAGS.__setattr__(backend.initializers.settings.db_host.name, "db_host")
    flags.FLAGS.__setattr__(backend.initializers.settings.db_port.name, "db_port")
    flags.FLAGS.__setattr__(backend.initializers.settings.app_secret_key.name, "app_secret_key")
    flags.FLAGS.__setattr__(backend.initializers.settings.mail_sender_email.name, "email@example.com")
    flags.FLAGS.__setattr__(backend.initializers.settings.mail_sender_password.name, "mail_password")
