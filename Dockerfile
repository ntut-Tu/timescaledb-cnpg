FROM ghcr.io/cloudnative-pg/postgresql:18-bookworm

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

ARG TIMESCALE_REPO_DISTRO=bookworm
ARG INSTALL_PGAI=false

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gnupg; \
    curl -fsSL https://packagecloud.io/timescale/timescaledb/gpgkey \
      | gpg --dearmor \
      | tee /usr/share/keyrings/timescaledb-archive-keyring.gpg > /dev/null; \
    source /etc/os-release; \
    repo_codename="${TIMESCALE_REPO_DISTRO:-$VERSION_CODENAME}"; \
    echo "deb [signed-by=/usr/share/keyrings/timescaledb-archive-keyring.gpg] https://packagecloud.io/timescale/timescaledb/debian/ ${repo_codename} main" \
      > /etc/apt/sources.list.d/timescaledb.list; \
    apt-get update; \
    packages=( \
      postgresql-contrib-18 \
      postgresql-18-postgis-3 \
      postgresql-18-postgis-3-scripts \
      postgresql-18-pgvector \
      postgresql-18-h3 \
      timescaledb-2-postgresql-18 \
      timescaledb-toolkit-postgresql-18 \
    ); \
    if [[ "${INSTALL_PGAI}" == "true" ]]; then \
      packages+=(postgresql-18-pgai); \
    fi; \
    for pkg in "${packages[@]}"; do \
      if ! apt-cache show "$pkg" >/dev/null 2>&1; then \
        echo "Package not found: $pkg (repo distro=${repo_codename}, base distro=${VERSION_CODENAME}, arch=$(dpkg --print-architecture))" >&2; \
        exit 1; \
      fi; \
    done; \
    apt-get install -y --no-install-recommends "${packages[@]}"; \
    required_extensions=( \
      postgis \
      postgis_topology \
      postgis_tiger_geocoder \
      fuzzystrmatch \
      vector \
      h3 \
      timescaledb \
      timescaledb_toolkit \
    ); \
    if [[ "${INSTALL_PGAI}" == "true" ]]; then \
      required_extensions+=(ai); \
    fi; \
    for ext in "${required_extensions[@]}"; do \
      if [[ ! -f "/usr/share/postgresql/18/extension/${ext}.control" ]]; then \
        echo "Extension control file not found: ${ext}.control" >&2; \
        exit 1; \
      fi; \
    done; \
    apt-get purge -y --auto-remove curl gnupg; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /var/cache/apt/archives/partial/*

USER 26