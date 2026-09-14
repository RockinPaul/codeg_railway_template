# Deploy and Host codeg on Railway

[codeg](https://github.com/xintaofei/codeg) is a collaborative multi-agent AI coding workspace. It
aggregates sessions from Claude Code, Codex, OpenCode, Pi, Grok Build and others behind a single web
interface, so several agents can work in one place with shared projects, folders and chat.

## About Hosting codeg

codeg is built to run as a server, not only as a desktop app: upstream publishes multi-architecture
container images and ships its own compose file. That makes hosting it unusually simple — one
service, no proxy in front, no build from source. The server speaks plain HTTP on a port it takes
from the environment, which is exactly the shape Railway's edge expects.

Two things need care. The workspace lives in SQLite, so it belongs on a volume that outlives a
redeploy. And access is guarded by a single token: codeg generates one at first boot if you do not
supply it, which means it is never accidentally open, but on a public URL you want that token to be
a strong generated value you can read back rather than a line buried in a log. This template pins it
to a Railway secret so both are true.

## Common Use Cases

- Run several coding agents against one project and compare their work in a shared interface.
- Keep a long-running agent workspace on a URL you can open from any machine.
- Give a team one place to watch and steer agent sessions instead of scattered local terminals.

## Dependencies for codeg Hosting

- A volume for the workspace database, which the template creates.
- Nothing else. No external database, no additional services.

### Deployment Dependencies

- [codeg](https://github.com/xintaofei/codeg) — the upstream project (Apache-2.0).
- Agent CLIs such as Claude Code or Codex, installed from inside the workspace and authenticated
  with your own accounts. They are not bundled.

### Implementation Details

One service runs the whole application, built from this template's repository as a thin pin of the
upstream image rather than a source build:

- **codeg** — the Rust server and the web UI in one image, with SQLite on the `/data` volume. The
  port, host and data directory are baked into the image rather than exposed as service variables,
  because a literal default would otherwise become a required field asking the deployer to type a
  port number. Only the access token remains a variable, generated as a Railway secret.

Railway mounts the volume root-owned with a lost and found directory at its root. codeg writes its
database alongside that without complaint, so this template needs no ownership fix-up at startup.
The health check is the site root, which serves the static shell before authentication, while every
API route returns 401 without the token.

Read `CODEG_TOKEN` from the service's variables after the first deploy, open the service URL, and
enter it. Then install the agent CLIs you want from a terminal in the workspace and authenticate
them with your own accounts.

Two limits are worth knowing. Agent CLIs you install at runtime live in the container layer, not on
the volume, so they must be reinstalled after a redeploy or added to a fork of the Dockerfile. And
codeg's in-place software update rewrites binaries inside the running container, which Railway
discards on the next deploy — bump the pinned version in the Dockerfile instead, which upstream's
own compose file recommends for the same reason.

## Why Deploy codeg on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your
infrastructure so you don't have to deal with configuration, while allowing you to vertically and
horizontally scale it.

By deploying codeg on Railway, you are one step closer to supporting a complete full-stack
application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
