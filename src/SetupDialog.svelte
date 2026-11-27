<script>
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import * as Dialog from "$lib/components/ui/dialog";
  import Cloud from "@lucide/svelte/icons/cloud";
  import Phone from "@lucide/svelte/icons/smartphone";

  let {
    open = $bindable(false),
    kind,
    value = $bindable(""),
    vault,
    account,
    onReturn,
  } = $props();
  let input = $state(null);
  let submittedValue = null;

  function focusField(event) {
    event.preventDefault();
    submittedValue = null;
    input?.focus();
    input?.select();
  }

  function submit(event) {
    event.preventDefault();
    const name = value.trim();
    if (!name) return;
    submittedValue = name;
    open = false;
  }

  function finishClose(event) {
    event.preventDefault();
    // Show the next assembly state once the dialog has released the screen.
    onReturn(submittedValue);
    submittedValue = null;
  }
</script>

<Dialog.Root bind:open>
  <Dialog.Content
    class="setup-dialog rounded-none"
    showCloseButton={false}
    onOpenAutoFocus={focusField}
    onCloseAutoFocus={finishClose}
  >
    <Dialog.Header class="dialog-heading">
      <span class="dialog-context">
        {#if kind === "device"}<Phone aria-hidden="true" /> Second-device preview
        {:else}<Cloud aria-hidden="true" /> Your cloud account{/if}
      </span>
      <Dialog.Title class="dialog-title">
        {kind === "device" ? "Join this keyring." : "Change sync account."}
      </Dialog.Title>
      <Dialog.Description class="dialog-description">
        {#if kind === "device"}Keep an encrypted copy of <strong>
            {vault}
          </strong> on this device.
        {:else}Choose the account that will hold your encrypted copy of <strong>
            {vault}
          </strong>.{/if}
      </Dialog.Description>
    </Dialog.Header>
    <form class="dialog-form" onsubmit={submit}>
      {#if kind === "device"}
        <div class="join-account">
          <Cloud aria-hidden="true" />
          <div><span>Your sync account</span><strong>{account}</strong></div>
        </div>
      {/if}
      <div class="field">
        <label for="setup-value">
          {kind === "device" ? "Device name" : "Cloud account email"}
        </label>
        <Input
          id="setup-value"
          class="setup-input rounded-none"
          bind:value
          bind:ref={input}
          type={kind === "device" ? "text" : "email"}
          pattern={kind === "device" ? ".*\\S.*" : undefined}
          title={kind === "device" ? "Enter a device name" : undefined}
          autocomplete="off"
          autocapitalize="none"
          spellcheck={false}
          required
        />
      </div>
      <Dialog.Footer class="dialog-actions">
        <Dialog.Close>
          {#snippet child({ props })}
            <Button
              {...props}
              type="button"
              variant="outline"
              class="cancel-action rounded-none"
            >
              Cancel
            </Button>
          {/snippet}
        </Dialog.Close>
        <Button type="submit" class="action rounded-none">
          {kind === "device" ? "Link this device" : "Save account"}
        </Button>
      </Dialog.Footer>
    </form>
  </Dialog.Content>
</Dialog.Root>
