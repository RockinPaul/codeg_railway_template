# codeg on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/codeg)

A collaborative multi-agent AI coding workspace — [codeg](https://github.com/xintaofei/codeg)
aggregates sessions from Claude Code, Codex, OpenCode and others behind one web UI, on a volume that
keeps your workspace across redeploys.

## Service

| Service | Image | Public | Role |
|---|---|---|---|
| `codeg` | `xintaofei/codeg:0.35.1` | **yes** | The whole application: Rust server, web UI, SQLite on `/data`. |

One service, no gateway. Upstream publishes multi-arch images, so this template is a thin pin
rather than a build, and codeg serves plain HTTP — which is exactly what Railway's edge expects.

## Variables

| Variable | Default | Purpose |
|---|---|---|
| `CODEG_TOKEN` | generated (32 hex) | Access token for the UI and the API. Read it from this service's variables after deploying. |
| `CODEG_PORT` | `8080` | Baked into the image. |
| `CODEG_HOST` | `0.0.0.0` | Baked. |
| `CODEG_DATA_DIR` | `/data` | Baked. Database and logs live here, on the volume. |

The template asks for nothing. `CODEG_TOKEN` is generated with `${{secret(32)}}`; read it from the
service's variables to sign in.

codeg is fail-closed either way: with no `CODEG_TOKEN` it generates one at first boot and prints it
to the log rather than serving unauthenticated. Pinning it as a Railway variable simply makes the
value stable and readable without digging through logs.

## What persists

The volume mounts at `/data` and holds `codeg.db` (SQLite) plus logs — your projects, sessions,
folders and settings. It survives redeploys.

Agent CLIs do **not** persist. The image ships Node, npm, Python and git but no agent binaries, so
`npm i -g` installs land in the container layer and are lost on the next redeploy. Reinstall them
after an upgrade, or fork this repository and add them to the Dockerfile.

## First run

1. Copy `CODEG_TOKEN` from the service's variables — it was generated for you.
2. Open the service URL and enter the token.
3. Install the agents you want from a terminal in the workspace, then authenticate them.

## Upgrading codeg

Bump `CODEG_VERSION` in the `Dockerfile` and push. Upstream releases every day or two.

Do **not** use codeg's in-place *Settings → Software Update*. It rewrites binaries inside the
running container's writable layer, which Railway discards on the next redeploy — upstream's own
compose file carries the same warning. Changing the pinned tag is the durable path.

## Notes on running it here

- **The image declares `VOLUME /data`.** Railway's own volume is mounted at the same path, which is
  what you want; the declaration is inherited from upstream and is not removed here.
- **The volume arrives root-owned with a `lost+found` directory.** codeg writes its database
  alongside it without complaint, so no entrypoint fix-up is needed — unusual, and verified.
- **The dev-server port bridge (0.35+) does not reach the browser here.** codeg can show a dev
  server an agent started (`localhost:3000` inside the container) through extra listeners on the
  ten ports after `CODEG_PORT`, gated by a per-listener capability that only a token holder can
  obtain. Railway routes only the service's one public port, so those listeners stay unreachable
  from outside. The alternative, `CODEG_BRIDGE_HOST_PATTERN`, serves dev servers through codeg's own
  port by hostname and needs a wildcard custom domain.
- **`/` is the health check.** It returns 200 and serves the static shell before you authenticate;
  every `/api/*` route returns 401 without the token.

## Security

Agents in this workspace can run commands, so treat the URL as privileged. The token is a 32-character
secret in a header, not a password with hashing and lockouts — good, but not a login system. Keep the
token private, and prefer a private network or VPN if the work is sensitive.

## Licences

codeg is [Apache-2.0](https://github.com/xintaofei/codeg/blob/main/LICENSE). The glue in this
repository is MIT.
