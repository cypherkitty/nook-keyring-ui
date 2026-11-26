<script>
  import { tick } from "svelte";
  import { Check, Laptop, Plus, Link2, Smartphone, Cloud } from "lucide-svelte";

  let stage = $state("create");
  let heading = $state();
  let created = $derived(stage !== "create");
  let paired = $derived(stage === "paired");

  async function advance() {
    stage = created ? "paired" : "link";
    await tick();
    heading.focus();
  }
</script>

<header class="masthead">
  <div class="brand"><img src="/nook.svg" alt="" />nook<span>.</span></div>
  <span class="descriptor">Local-first password manager</span>
</header>

<main>
  <ol class="steps" aria-label="Vault setup progress">
    <li
      class:current={!created}
      class:complete={created}
      aria-current={!created ? "step" : undefined}
    >
      <span class="number">
        {#if created}<Check size={14} />{:else}1{/if}
      </span>Create vault
    </li>
    <li
      class:current={created && !paired}
      class:complete={paired}
      aria-current={created && !paired ? "step" : undefined}
    >
      <span class="number">
        {#if paired}<Check size={14} />{:else}2{/if}
      </span>Add device
    </li>
  </ol>

  <section class="setup-card" aria-labelledby="setup-title">
    <div class="content">
      <div class="device-label">
        {#if created}<Link2 size={16} />{paired
            ? "Your keyring"
            : "Next device"}{:else}<Laptop size={16} />This device{/if}
      </div>
      <h1 id="setup-title" tabindex="-1" bind:this={heading}>
        {#if !created}Create your<br />local vault.{:else if !paired}Add another<br
          />device.{:else}Your devices<br />are linked.{/if}
      </h1>
      <p>
        {#if !created}Keep your passwords on this device in a vault of your own.{:else if !paired}On
          your next device, connect to the same Dropbox account to link it to
          your vault.{:else}Both devices now belong to the same keyring and
          share one vault.{/if}
      </p>
      {#if !paired}
        <button class="primary" onclick={advance}>
          {#if created}<Link2 size={17} />Link with Dropbox{:else}<Plus
              size={18}
            />Create vault{/if}
        </button>
      {:else}
        <span class="finished"><Check size={16} />2 devices linked</span>
      {/if}
    </div>

    {#if !created}
      <div class="art" aria-hidden="true"></div>
    {:else}
      <div class="diagram" aria-hidden="true">
        <div class="device-node"><Laptop size={42} strokeWidth={1.35} /></div>
        <span class="connection"></span><span class="provider">
          <Cloud size={24} />
        </span><span class="connection"></span>
        <div class="device-node" class:pending={!paired}>
          <Smartphone size={39} strokeWidth={1.35} />
        </div>
      </div>
    {/if}
  </section>
  <small class="preview-note">Interactive preview</small>
</main>
