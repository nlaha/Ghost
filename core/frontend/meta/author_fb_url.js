const getContextObject = require("./context_object.js");
const _ = require("lodash");

function getAuthorFacebookUrl(data) {
    const context = data.context ? data.context : null;
    const contextObject = getContextObject(data, context);

    if (
        (_.includes(context, "post") ||
            _.includes(context, "page") ||
            _.includes(context, "galleryimage")) &&
        contextObject.primary_author &&
        contextObject.primary_author.facebook
    ) {
        return contextObject.primary_author.facebook;
    } else if (_.includes(context, "author") && contextObject.facebook) {
        return contextObject.facebook;
    }
    return null;
}

module.exports = getAuthorFacebookUrl;
