module.exports = require("error-doc").create()
    .define("NotFound")
    .define("AlreadyExists")
    .define("InvalidParameters")
    .define("AuthorizationFailed")
    .define("ServerError")
    .generate()
