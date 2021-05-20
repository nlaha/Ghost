const debug = require("ghost-ignition").debug(
    "api:canary:utils:serializers:output:galleryimages"
);
const mapper = require("./utils/mapper");

module.exports = {
    all(models, apiConfig, frame) {
        debug("all");

        // CASE: e.g. destroy returns null
        if (!models) {
            return;
        }

        if (models.meta) {
            frame.response = {
                galleryimages: models.data.map((model) =>
                    mapper.mapPage(model, frame)
                ),
                meta: models.meta,
            };

            return;
        }

        frame.response = {
            galleryimages: [mapper.mapPage(models, frame)],
        };
    },
};
