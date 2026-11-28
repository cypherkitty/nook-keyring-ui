<script>
  import { tick } from "svelte";
  import Chevron from "@lucide/svelte/icons/chevron-right";
  import Mail from "@lucide/svelte/icons/mail";
  import Plus from "@lucide/svelte/icons/plus";
  import { Button } from "$lib/components/ui/button";

  let { example, onExample } = $props();
  let library;
  let revealed = $state(false);

  async function setExample(value) {
    revealed = false;
    onExample(value);
    await tick();
    library.querySelector(value ? "summary" : ".add-example")?.focus();
  }
</script>

<section class="passwords" aria-labelledby="passwords-heading" bind:this={library}>
  <div class="passwords-toolbar">
    <h2 id="passwords-heading">Passwords <span>{example ? 1 : 0}</span></h2>
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
