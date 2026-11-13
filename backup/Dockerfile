# mongodump comes with the official mongo image; rclone is copied from its official image.
FROM rclone/rclone:1.68.2 AS rclone

FROM mongo:8.0

ARG TARGETARCH
ARG SUPERCRONIC_VERSION=v0.2.33

COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone

# supercronic: cron for containers (keeps env vars, logs to stdout)
ADD https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH} /usr/local/bin/supercronic
RUN chmod +x /usr/local/bin/supercronic

COPY backup.sh /usr/local/bin/backup.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/backup.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
