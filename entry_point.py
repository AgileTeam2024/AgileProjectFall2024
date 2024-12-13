from absl import app as absl_app

# Load settings for the defined flags to be parsed before running the app.
# This ensures that any required configurations are available when initializing the Flask app.
import app.initializers.settings


def main(_: list[str]) -> None:
    """
       Main entry point for running the Flask application.

       Args:
           _: A list of command-line arguments (not used in this function).
    """

    import app.app as flask_app

    # TODO: Use "waitress" to run the app in production.
    # This TODO is done when local deployment is done, and the app is production-ready.
    flask_app.create_flask_app().run(host='0.0.0.0', port=8000)


if __name__ == '__main__':
    absl_app.run(main)
