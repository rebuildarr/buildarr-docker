# Dockerfile
# Buildarr Docker image.
#
# Copyright (C) 2023 Callum Dickinson
#
# Buildarr is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Buildarr is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Buildarr.
# If not, see <https://www.gnu.org/licenses/>.

FROM python:3.11-alpine

# Ensure stdout/stderr writes straight through to the Docker logs without buffering.
ENV PYTHONUNBUFFERED=1

# Buildarr user UID/GID. User is created at runtime.
ENV PUID=1000
ENV PGID=1000

# Mark the Buildarr configuration folder as an external volume mount point.
VOLUME ["/config"]

# Copy the container bootstrap script into the image.
COPY bootstrap.sh /bootstrap.sh

# Run the image setup script.
RUN apk add su-exec tzdata git && \
    chmod +x /bootstrap.sh && \
    python -m pip install --no-cache-dir git+https://github.com/rebuildarr/buildarr.git@main \
            git+https://github.com/rebuildarr/buildarr-radarr.git@main \
            git+https://github.com/rebuildarr/buildarr-sonarr.git@main \
            git+https://github.com/rebuildarr/buildarr-prowlarr.git@main \
            git+https://github.com/rebuildarr/buildarr-jellyseerr.git@main

# Set the Buildarr configuration folder as the default Docker container working folder.
WORKDIR /config

# Setup the Docker image entry point to bootstrap packages and start Buildarr daemon.
ENTRYPOINT ["/bootstrap.sh"]
CMD ["daemon"]
