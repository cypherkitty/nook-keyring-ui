<script>
  import { tick } from "svelte";
  import { CheckCheck, Link2, Plus } from "lucide-svelte";
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
  <div class="brand" aria-label="Nook">
    <img src="/nook.svg" alt="" />nook<span>.</span>
  </div>
  <span class="descriptor">Local-first password manager</span>
</header>

<main>
  <div class="introduction">
    <h1>Your vault lives on <em>your devices.</em></h1>
    <p>Dropbox keeps an encrypted copy in sync between them.</p>
  </div>

  <section class="setup" aria-label="How your devices share a vault">
    <VaultDiagram {created} {linked} />

    <div class="action-bar">
      {#if !linked}
        <div class="next-step" aria-live="polite" aria-atomic="true">
          <span class="step-count">Step {created ? "2" : "1"} of 2</span>
          <p>
            {created
              ? "Connect the same Dropbox account on your other device."
              : "Start on this device."}
          </p>
        </div>
        <button class="primary" onclick={advance}>
          {#if created}<Link2 size={17} />Link with Dropbox{:else}<Plus
              size={17}
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
  <small class="preview-note">Interactive preview</small>
</main>
