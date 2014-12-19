# TODO

* Rails 4 support? Has anything changed there?

* Technically ActionDispatch::Cookie is just middleware, I wonder if we replace it entirely to do our work in subclasses.
* We'd have to get `config.deprecated_secret_token` into the env if we wrote our own middleware. `Rails::Application#env_config` could be the answer?
