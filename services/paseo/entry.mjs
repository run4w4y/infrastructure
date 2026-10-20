import { readFileSync, mkdirSync } from 'node:fs';
import { spawn } from 'node:child_process';
import { pathToFileURL } from 'node:url';

const paths = JSON.parse(readFileSync(new URL('./runtime.json', import.meta.url), 'utf8'));
const home = process.env.MY_PI_PASEO_HOME || '/var/lib/paseo/daemon';
const { AGENT_PROVIDER_DEFINITIONS, DEV_AGENT_PROVIDER_DEFINITIONS } = await import(
  pathToFileURL(`${paths.runtime}/node_modules/@getpaseo/protocol/dist/provider-manifest.js`)
);
const providers = [...new Set([
  ...AGENT_PROVIDER_DEFINITIONS.map(provider => provider.id),
  ...DEV_AGENT_PROVIDER_DEFINITIONS.map(provider => provider.id),
  'antigravity', 'muse', 'hoplite',
])];

if (process.argv[2] === 'render-config') {
  const { configurePaseo } = await import(pathToFileURL(`${paths.resources}/scripts/paseo-configuration.ts`));
  const config = configurePaseo({}, '/app/local-execution-disabled',
    '__PASEO_PASSWORD_HASH__',
    `${paths.resources}/paseo-plugin`, undefined,
    { quote: `${paths.runtime}/node_modules/paseo-quote`, 'paseo-document-viewer': paths.documents });
  for (const provider of providers) config.agents.providers[provider] = {
    ...config.agents.providers[provider], enabled: false,
  };
  config.daemon.mcp.enabled = false;
  config.daemon.browserTools.enabled = false;
  config.agents.metadataGeneration = { providers: [] };
  process.stdout.write(JSON.stringify(config, null, 2) + '\n');
  process.exit(0);
}

const config = JSON.parse(readFileSync(`${home}/config.json`, 'utf8'));
for (const provider of providers) {
  if (config.agents?.providers?.[provider]?.enabled !== false)
    throw new Error(`Bootstrap role requires provider '${provider}' disabled`);
}
for (const [provider, value] of Object.entries(config.agents.providers)) {
  if (value.enabled !== false) throw new Error(`Unexpected enabled provider '${provider}'`);
}
if (config.daemon.listen !== '127.0.0.1:6767' || config.daemon.relay.enabled !== false)
  throw new Error('Bootstrap daemon must retain private loopback and disabled relay');
if (config.plugins?.['prompt-suggestions']?.enabled === true)
  throw new Error('Local prediction generation is unavailable in the bootstrap role');
for (const path of [home, '/var/lib/paseo/agent', '/var/lib/paseo/cache', '/var/lib/paseo/repositories'])
  mkdirSync(path, { recursive: true, mode: 0o700 });

const child = spawn(paths.node, [
  `${paths.runtime}/node_modules/@getpaseo/cli/dist/index.js`, 'daemon', 'run', '--home', home,
], {
  stdio: 'inherit', env: {
    ...process.env, MY_PI_RUNTIME: paths.runtime, MY_PI_RESOURCES: paths.resources,
    MY_PI_NONO: paths.nono, MY_PI_SANDBOX_PROTOCOL: '2', MY_PI_NONO_BASE_PROFILE: paths.profile,
    MY_PI_INSTRUCTIONS: paths.instructions,
    MY_PI_ENFORCEMENT_PROBE: `${paths.enforcement}/bin/my-pi-enforcement-probe`,
    MY_PI_PROCESS_SUPERVISOR: `${paths.enforcement}/bin/my-pi-process-supervisor`,
    PI_CODING_AGENT_DIR: '/var/lib/paseo/agent', MY_PI_REQUIRE_PASEO_POLICY: '1',
  },
});
for (const signal of ['SIGTERM', 'SIGINT']) process.on(signal, () => child.kill(signal));
child.on('error', error => { process.stderr.write(error.message + '\n'); process.exit(1); });
child.on('exit', code => process.exit(code ?? 1));
