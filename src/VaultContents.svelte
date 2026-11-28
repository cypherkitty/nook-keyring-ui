<script>
  import { tick } from "svelte";
  import ChevronRight from "@lucide/svelte/icons/chevron-right";
  import Key from "@lucide/svelte/icons/key-round";
  import Mail from "@lucide/svelte/icons/mail";
  import Plus from "@lucide/svelte/icons/plus";
  import { Button } from "$lib/components/ui/button";

  let { stage, example, inline, onExample } = $props();
  let library;
  let revealed = $state(false);
  const artwork = import.meta.env.BASE_URL + "keyring/";
  const cover = $derived(stage === "linked" ? "vault-ring.webp" : stage === "cloud" ? "cloud-copy.webp" : "local-vault.webp");

  async function setExample(value) {
    revealed = false;
    onExample(value);
    await tick();
    library.querySelector(value ? ".example-login summary" : ".add-example")?.focus();
  }
</script>

<section class="resource-view library" class:in-workspace={inline} aria-labelledby="passwords-heading" bind:this={library}>
  <div class="view-toolbar">
    <div class="collection-title">
      <h2 id="passwords-heading">Passwords</h2>
      <span class="item-count">{example ? 1 : 0}</span>
    </div>
    {#if !example}
      <Button variant="outline" class="add-example secondary-action rounded-none" onclick={() => setExample(true)}>
        <Plus aria-hidden="true" /> Add example login
      </Button>
    {/if}
  </div>
  {#if !inline || example}<div class="password-list">
    {#if example}
      <details class="example-login">
        <summary>
          <span class="login-icon"><Mail aria-hidden="true" /></span>
          <span><strong>Example Mail</strong><small>reader@example.com</small></span>
          <ChevronRight aria-hidden="true" />
        </summary>
        <div class="login-details">
          <div class="example-secret">
            <span>Example password</span>
            <code aria-live="polite">{revealed ? "nook-example-only" : "••••••••••••"}</code>
            <button type="button" aria-pressed={revealed} onclick={() => revealed = !revealed}>
              {revealed ? "Hide" : "Show"}
            </button>
          </div>
          <button type="button" class="text-action" onclick={() => setExample(false)}>Remove example</button>
        </div>
      </details>
    {:else}
      <div class="empty-passwords"><Key aria-hidden="true" /><span>No saved passwords</span></div>
    {/if}
  </div>{/if}
  {#if !inline}<a class="keyring-shortcut" href="#keyring">
    <img src={artwork + cover} width="80" height="60" alt="" />
    <span><strong>My keyring</strong>
      <small>{stage === "linked" ? "2 devices in sync" : stage === "cloud" ? "Link a second device" : "Connect your cloud to link another device"}</small>
    </span>
    <ChevronRight aria-hidden="true" />
  </a>{/if}
</section>
