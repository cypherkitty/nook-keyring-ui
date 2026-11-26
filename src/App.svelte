<script>
  import { tick } from "svelte";
  import { CheckCheck, Link2, MousePointer2, Plus } from "lucide-svelte";
  import VaultDiagram from "./VaultDiagram.svelte";

  let stage = $state("create");
  let completion = $state();
  const created = $derived(stage !== "create");
  const linked = $derived(stage === "linked");

  async function advance() {
    if (!created) {
      stage = "link";
      return;
    }
    stage = "linked";
    await tick();
    completion.focus({ preventScroll: true });
  }
</script>

<header class="masthead">
  <div class="identity">
    <div class="brand" aria-label="Nook">
      <img src="/nook.svg" alt="" />nook<span>.</span>
    </div>
    <span class="descriptor">Local-first password manager</span>
  </div>
  <small class="preview-note">
    <MousePointer2 size={15} aria-hidden="true" />Interactive preview
  </small>
</header>

<main>
  <div class="introduction">
    <h1>Your vault lives on <em>your devices.</em></h1>
    <p>
      Change a password on one device and it syncs to the other through your
      cloud account.
    </p>
  </div>

  <section class="setup" aria-label="How your devices share a vault">
    <VaultDiagram {created} {linked} />

    <div class="action-bar">
      {#if !linked}
        <div class="next-step" aria-live="polite" aria-atomic="true">
          <div class="progress">
            <span
              class="progress-track"
              class:second={created}
              aria-hidden="true"
            >
              <i></i><i></i>
            </span>
            <span>Step {created ? "2" : "1"} of 2</span>
          </div>
          <p>
            {created
              ? "Use the same cloud account on both devices."
              : "Start on this device."}
          </p>
        </div>
        <button class="primary" onclick={advance}>
          {#if created}<Link2 size={17} aria-hidden="true" />Link device{:else}<Plus
              size={18}
              aria-hidden="true"
            />Create vault{/if}
        </button>
      {:else}
        <div class="completion" tabindex="-1" bind:this={completion}>
          <span class="success-icon"><CheckCheck size={20} /></span>
          <div>
            <strong>Devices linked</strong>
            <p>Both devices now share one vault in your keyring.</p>
          </div>
        </div>
      {/if}
    </div>
  </section>
</main>
