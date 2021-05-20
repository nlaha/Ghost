const jsonSchema = require("@tryghost/admin-api-schema");

/**
 *
 * @param {Object} apiConfig "frame" api configuration object
 * @param {string} apiConfig.docName the name of the resource
 * @param {string} apiConfig.method API's method name
 * @param {Object} frame "frame" object with data attached to it
 * @param {Object} frame.data request data to validate
 */
const validate = async (apiConfig, frame) => {
    let docname = apiConfig.docName;
    if (apiConfig.docName === "galleryimages") {
        return true;
    }
    return await jsonSchema.validate({
        data: frame.data,
        schema: `${docname}-${apiConfig.method}`,
        version: "canary",
    });
};

module.exports.validate = validate;
