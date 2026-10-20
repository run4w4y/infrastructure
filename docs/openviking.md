# Operate OpenViking

OpenViking runs as Nomad job `openviking` at
[memory.4w4y.run](https://memory.4w4y.run). The application uses native API-key
authentication. Traefik reaches the service through Consul Connect.

## Review and deploy changes

The job and template belong to `terraform/modules/nomad/jobs/openviking/`.
The Nomad module owns its two persistent host volumes and server workload
identity. Consul owns the service intention. Vault owns the client-provisioner
policy.

Review changes through the existing Nomad workspace:

```sh
zsh -ilc 'cd /home/adachi/infrastructure/terraform/live/interserver-run4w4y/nomad && terragrunt plan'
```

After reviewing the full workspace plan, run `terragrunt apply` in the same
environment. Apply changed Consul intentions before the job. The providers use
the operator Access credentials from Infisical's `/terraform` folder.

Use a private native CLI session to inspect the job:

```sh
nomad job status openviking
```

The group HTTP check controls ingress health. The task-level
`openviking-process` check owns server restart behavior. Keep restart checks on
the server task so a server failure does not restart the model worker.

## Connect a client

Use a trusted Vault session or the `openviking-client-provisioner` policy to read
KV v2 mount `secret`, path `openviking/client`. The fields are `api_key`,
`account_id`, `user_id`, and `endpoint`. Send the application key in `X-API-Key`.
The server's root credential remains at `secret/openviking/server`.

Store client credentials outside Git and use the application's credential
storage. Python SDK clients need a client User-Agent that the Cloudflare edge
accepts. The default `Python-urllib` User-Agent can receive error 1010.

Wait for indexing after writes before checking search results. A successful
write does not mean its vectors are ready.

## Preserve model and storage compatibility

The job pins these images:

| Component | Image |
| --- | --- |
| OpenViking | `ghcr.io/volcengine/openviking@sha256:c60a83cd79cfce80db5266acb8bdd0908eee8abe8ff559a5f786aa504c251ccf` |
| Ollama | `ollama/ollama:0.13.1@sha256:8850b8b33936b9fb246e7b3e02849941f1151ea847e5fb15511f17de9589aea1` |

Startup tasks prepare `embeddinggemma:300m-qat-q4_0` and `qwen3:0.6b`, then warm
both providers before starting the server. Both use a 2,048-token context.
The embedding dimension is 768 and the vector collection is
`context_gemma_q4_fixed_768`.

The job retains the OpenAI SDK startup preload and its prompt templates.
Generated summaries have a 192-token ceiling. Individual files retain their
complete source text and vectors.

Back up `openviking-data`, `openviking-models`, and the corresponding Vault data.
Keep the embedding model and vector configuration compatible when restoring an
index. Model changes require a reindex. Check current Nomad reservations and
host memory before adding workloads to the shared node.
