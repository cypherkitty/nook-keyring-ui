<script>
  import { tick } from "svelte";
  import Chevron from "@lucide/svelte/icons/chevron-right";
  import Mail from "@lucide/svelte/icons/mail";
  import Plus from "@lucide/svelte/icons/plus";
  import { Button } from "$lib/components/ui/button";

  let { vault, example, onExample } = $props();
  let library;
  let revealed = $state(false);

  async function setExample(value) {
    revealed = false;
    onExample(value);
    await tick();
    library.querySelector(value ? "summary" : ".add-example")?.focus();
  }
</script>

<section class="passwords" aria-labelledby="vault" bind:this={library}>
  <div class="passwords-toolbar">
    <div class="passwords-title">
      <h2 id="vault" tabindex="-1" title={vault}>{vault}</h2>
      <span>{example ? "1 password" : "0 passwords"}</span>
    </div>
    {#if !example}
      <Button variant="outline" class="add-example secondary-action rounded-none" onclick={() => setExample(true)}>
        <Plus aria-hidden="true" />Add example login
      </Button>
    {/if}
  </div>
  {#if example}
    <details class="example-login">
      <summary>
        <Mail aria-hidden="true" />
        <span><strong>Example Mail</strong><small>reader@example.com</small></span>
        <Chevron aria-hidden="true" />
      </summary>
      <div class="login-details">
        <div class="example-secret">
          <span>Example password</span>
          <code aria-live="polite">{revealed ? "nook-example-only" : "••••••••••••"}</code>
          <button type="button" class="text-action" aria-pressed={revealed} onclick={() => revealed = !revealed}>
            {revealed ? "Hide" : "Show"}
          </button>
        </div>
        <button type="button" class="text-action" onclick={() => setExample(false)}>Remove example</button>
      </div>
    </details>
  {:else}
    <p class="empty-list">No saved passwords</p>
  {/if}
</section>
