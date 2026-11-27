<script>
  import { onDestroy, tick } from "svelte";
  import { Check, Link2, Plus, RefreshCw, RotateCcw } from "lucide-svelte";
  import KeyringMap from "./KeyringMap.svelte";

  // A zero is a planned location. Positive values identify the demo vault revision.
  let copies = $state([0, 0, 0]);
  let transfer = $state(null);
  let primaryButton = $state();
  let timers = [];
  const created = $derived(copies[0] > 0);
  const linked = $derived(copies[2] > 0);
  const revision = $derived(Math.max(...copies));
  const nextSource = $derived(linked && revision % 2 === 0 ? 2 : 0);
  const actionNode = $derived(
    created && !linked ? 2 : (transfer?.source ?? nextSource),
  );

  function clearTimers() {
    timers.forEach(clearTimeout);
    timers = [];
  }
  onDestroy(clearTimers);

  async function reset() {
    clearTimers();
    transfer = null;
    copies = [0, 0, 0];
    await tick();
    primaryButton?.focus();
  }

  function sendCopy(source, target, version) {
    const receive = () => {
      copies[target] = version;
      transfer = null;
      timers = [];
    };
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      copies[1] = version;
      receive();
      return;
    }
    transfer = { source, from: source, to: 1 };
    timers = [
      setTimeout(() => {
        copies[1] = version;
        transfer = { source, from: 1, to: target };
      }, 650),
      setTimeout(receive, 1300),
    ];
  }

  function advance() {
    if (transfer) return;
    if (!created) {
      copies[0] = 1;
      return;
    }
    if (!linked) {
      sendCopy(0, 2, copies[0]);
      return;
    }
    const source = nextSource;
    const version = revision + 1;
    copies[source] = version;
    sendCopy(source, 2 - source, version);
  }

  const title = $derived(
    !created
      ? "Create your local vault."
      : !linked
        ? "Add your next device."
        : "Your vault is in sync.",
  );
  const actionLabel = $derived(
    transfer
      ? "Syncing…"
      : !created
        ? "Create vault"
        : !linked
          ? "Link device"
          : "Preview a change",
  );
  const status = $derived(
    transfer
      ? transfer.to === 1
        ? "Sending the encrypted copy to your cloud account."
        : "Delivering the copy to the other device."
      : !created
        ? "Create the first copy on this device."
        : !linked
          ? "Local vault created. Ready to link your other device."
          : `All three locations have vault version ${revision}.`,
  );
</script>

<header class="masthead">
  <div class="identity">
    <div class="brand" aria-label="Nook">
      <img src="/nook.svg" alt="" />nook<span>.</span>
    </div>
    <span class="descriptor">Local-first password manager</span>
  </div>
  {#if created}
    <button class="reset" onclick={reset}>
      <RotateCcw size={14} aria-hidden="true" />Reset preview
    </button>
  {:else}
    <small class="preview-label">Interactive preview</small>
  {/if}
</header>

<main>
  <div class="introduction">
    <div class="phase">
      {#if linked}<Check size={15} aria-hidden="true" />Devices linked{:else}<span
          class="step-bars"
          aria-hidden="true"
        >
          <i></i><i class:active={created}></i>
        </span>Step {created ? "2" : "1"} of 2{/if}
    </div>
    <h1>{transfer && linked ? "Updating your vault." : title}</h1>
    <p>
      {#if !created}
        When you sync, Nook saves an encrypted copy of your vault in
        <strong>your own cloud account</strong>. A hosted password manager keeps
        that copy on its servers.
      {:else if !linked}
        Connect both devices to the same cloud account. Your encrypted vault
        will be stored in that account and on each device.
      {:else}
        Your cloud account and both devices now hold the same encrypted vault.
        Preview a password change to see it sync.
      {/if}
    </p>
  </div>

  <section class="sheet" aria-labelledby="map-title">
    <div class="sheet-header">
      <h2 id="map-title">Your keyring</h2>
      <span class="legend">
        <span class="legend-file" aria-hidden="true"></span>Encrypted vault
      </span>
    </div>
    <KeyringMap {copies} {transfer} {actionNode}>
      {#snippet action()}
        <button
          bind:this={primaryButton}
          class="primary"
          aria-disabled={!!transfer}
          onclick={advance}
        >
          {#if !created}<Plus size={16} aria-hidden="true" />
          {:else if !linked}<Link2 size={16} aria-hidden="true" />
          {:else}<RefreshCw size={15} aria-hidden="true" />{/if}
          {actionLabel}
        </button>
      {/snippet}
    </KeyringMap>
  </section>
  <p class="sr-only" role="status" aria-live="polite">{status}</p>
</main>
