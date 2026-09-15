const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');
const { test } = require('node:test');

const workflow = name => readFileSync(resolve(__dirname, '../workflows', name), 'utf8');
const android = workflow('android-daily-early.yml');
const script = android.match(/          script: \|\n([\s\S]*?)\n  build-android-early:/)[1]
  .replace(/^            /gm, '');
const runCheck = new (Object.getPrototypeOf(async function () {}).constructor)(
  'github', 'context', 'core', 'process', script,
);
const release = (overrides = {}) => ({
  tag_name: 'android-early-20260915-abc1234',
  prerelease: true, draft: false, published_at: '2026-09-15T00:00:00Z',
  assets: ['app-cnearly-release.apk', 'app-globalearly-release.apk'].map(name =>
    ({ name, size: 1024, state: 'uploaded' })),
  ...overrides,
});
async function check({ releases = [release()], sha = 'same', force = false, error } = {}) {
  const output = {};
  const refs = [];
  let listed = false;
  const github = {
    paginate: async () => { listed = true; if (error) throw error; return releases; },
    rest: { repos: {
      listReleases: {},
      getCommit: async ({ ref }) => { refs.push(ref); return { data: { sha } }; },
    } },
  };
  await runCheck(github, { repo: { owner: 'test', repo: 'test' }, sha: 'same' },
    { setOutput: (key, value) => { output[key] = value; }, info: () => {} },
    { env: { FORCE_BUILD: String(force) } });
  return { ...output, refs, listed };
}

test('unchanged published commit skips the build', async () => {
  assert.equal((await check()).should_build, 'false');
});
test('changed commit builds', async () => {
  assert.equal((await check({ sha: 'different' })).should_build, 'true');
});
test('first release builds', async () => {
  assert.equal((await check({ releases: [] })).should_build, 'true');
});
test('manual force builds without release API lookup', async () => {
  const result = await check({ force: true, error: new Error('unavailable') });
  assert.equal(result.should_build, 'true');
  assert.equal(result.listed, false);
});
test('draft, stable, unrelated and incomplete releases are not baselines', async () => {
  for (const overrides of [
    { draft: true }, { prerelease: false }, { tag_name: 'v1.0.0' },
    { assets: release().assets.slice(0, 1) },
    { assets: release().assets.map(asset => ({ ...asset, size: 0 })) },
    { assets: release().assets.map(asset => ({ ...asset, state: 'starter' })) },
  ]) {
    assert.equal((await check({ releases: [release(overrides)] })).should_build, 'true');
  }
});
test('selects newest complete published Early release', async () => {
  const result = await check({ releases: [
    release({ tag_name: 'android-early-old', published_at: '2026-09-01T00:00:00Z' }),
    release(),
    release({ tag_name: 'android-early-partial', published_at: '2026-09-16T00:00:00Z', assets: [] }),
  ] });
  assert.deepEqual(result.refs, [release().tag_name]);
});
test('resolves tag rather than trusting a moving target_commitish', async () => {
  const result = await check({ releases: [release({ target_commitish: 'main' })] });
  assert.equal(result.should_build, 'false');
  assert.deepEqual(result.refs, [release().tag_name]);
});
test('accepts configured custom APK output names', async () => {
  const assets = ['cnEarly', 'globalEarly'].map(flavor =>
    ({ name: `memex_${flavor}_1.0_123.apk`, state: 'uploaded', size: 1024 }));
  assert.equal((await check({ releases: [release({ assets })] })).should_build, 'false');
});
test('API failure fails precheck instead of silently skipping', async () => {
  await assert.rejects(check({ error: new Error('API unavailable') }), /API unavailable/);
});
test('PR events skip drafts, run ready PRs, and retain manual AI override', () => {
  for (const name of ['pr-flutter-quality.yml', 'pr-ai-review.yml']) {
    const source = workflow(name);
    const expression = source.match(/^    if: \$\{\{ (.+) \}\}$/m)[1];
    const evaluate = new Function('github', `return ${expression};`);
    for (const action of ['opened', 'synchronize', 'reopened', 'ready_for_review', 'converted_to_draft']) {
      assert.ok(source.match(/types: \[(.+)\]/)[1].includes(action));
      for (const draft of [true, false]) {
        assert.equal(evaluate({ event_name: 'pull_request', event: { action, pull_request: { draft } } }), !draft);
      }
    }
    if (name === 'pr-ai-review.yml') {
      assert.equal(evaluate({ event_name: 'workflow_dispatch', event: {} }), true);
    }
  }
});
