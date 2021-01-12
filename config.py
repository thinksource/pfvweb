class Config(object):
    """Base config, uses staging database server."""
    DEBUG = False
    DB = 'tdb'
    USER = 'postgres'
    PASSWORD = 'password'
    DB_SERVER = '172.29.35.56'
    static_url_path=""