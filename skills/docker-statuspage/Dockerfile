# TODO (you write this file). Read the Dockerfile reference + "Building best practices" first.
#
# Required (criteria 1, 4, 5, 6, 8 in TASK.md):
#   - FROM an official nginx image that runs as a non-root user, pinned to an exact
#     version tag (e.g. <name>:<major.minor.patch>-alpine). No :latest, no untagged image.
#   - ARG APP_VERSION with a default of "dev"
#   - LABEL org.opencontainers.image.source, .title and .version (version = APP_VERSION)
#   - COPY your nginx/default.conf over the image's default server config
#   - COPY site/ into the directory your nginx config serves
#   - EXPOSE 8080
#   - HEALTHCHECK that calls /healthz (check which HTTP client exists in your base image:
#     alpine images ship busybox wget, not curl)
#   - USER must NOT be root (check: docker run --rm statuspage:dev id -u  -> not 0)
#
# Hint: order instructions so the layer that changes most often (site/) comes last.
