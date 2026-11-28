<script>
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import * as Dialog from "$lib/components/ui/dialog";
  import Cloud from "@lucide/svelte/icons/cloud";

  let {
    open = $bindable(false),
    kind,
    value = $bindable(""),
    vault,
    account,
    onReturn,
  } = $props();
  let input = $state(null);
  let cancelButton = $state(null);
  let submittedValue = null;
  const actions = {
    device: { title: "Link your second device", submit: "Add to keyring" },
    cloud: { title: "Change cloud account", submit: "Save account" },
    reset: { title: "Reset this workspace?", submit: "Reset workspace" },
  };

  function focusField(event) {
    event.preventDefault();
    submittedValue = null;
    if (kind === "reset") cancelButton?.focus();
    else {
      input?.focus();
      input?.select();
    }
  }

  function submit(event) {
    event.preventDefault();
    const name = kind === "reset" ? "reset" : value.trim();
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
      <Dialog.Title class="dialog-title">
        {actions[kind].title}
      </Dialog.Title>
      <Dialog.Description class="dialog-description">
        {#if kind === "reset"}Clear the vault name, linked devices and sample data saved in this browser.
        {:else if kind === "device"}Use the same cloud account to open <strong>
            {vault}
          </strong> on that device.
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
      {#if kind !== "reset"}
        <div class="field">
          <label for="setup-value">{kind === "device" ? "Device name" : "Cloud account email"}</label>
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
      {/if}
      <Dialog.Footer class="dialog-actions">
        <Dialog.Close>
          {#snippet child({ props })}
            <Button
              {...props}
              bind:ref={cancelButton}
              type="button"
              variant="outline"
              class="cancel-action rounded-none"
            >
              Cancel
            </Button>
          {/snippet}
        </Dialog.Close>
        <Button type="submit" class="action rounded-none">
          {actions[kind].submit}
        </Button>
      </Dialog.Footer>
    </form>
  </Dialog.Content>
</Dialog.Root>
