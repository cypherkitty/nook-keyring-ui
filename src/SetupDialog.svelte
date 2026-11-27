<script>
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import * as Dialog from "$lib/components/ui/dialog";
  import Cloud from "@lucide/svelte/icons/cloud";
  import Laptop from "@lucide/svelte/icons/laptop";
  import Phone from "@lucide/svelte/icons/smartphone";

  let {
    open = $bindable(false),
    kind,
    value = $bindable(""),
    vault,
    account,
    onSave,
    onReturn,
  } = $props();
  let input = $state(null);
  let submitted = false;
  const namePattern = ".*\\S.*";
  const forms = {
    vault: {
      icon: Laptop,
      context: "This device",
      title: "Name your vault",
      label: "Vault name",
      submit: "Create vault",
    },
    cloud: {
      icon: Cloud,
      context: "Your storage",
      title: "Connect your cloud account",
      label: "Account email",
      submit: "Connect account",
    },
    device: {
      icon: Phone,
      context: "Second-device preview",
      title: "Join this keyring",
      label: "Device name",
      submit: "Link this device",
    },
  };
  const form = $derived(forms[kind]);

  function focusField(event) {
    event.preventDefault();
    submitted = false;
    input?.focus();
    input?.select();
  }

  function submit(event) {
    event.preventDefault();
    const name = value.trim();
    if (!name) return;
    submitted = true;
    onSave(kind, name);
    open = false;
  }

  function returnFocus(event) {
    event.preventDefault();
    onReturn(submitted);
  }
</script>

<Dialog.Root bind:open>
  <Dialog.Content
    class="setup-dialog rounded-none"
    showCloseButton={false}
    onOpenAutoFocus={focusField}
    onCloseAutoFocus={returnFocus}
  >
    <Dialog.Header class="dialog-heading">
      <span class="dialog-context">
        <form.icon strokeWidth={1.7} aria-hidden="true" />{form.context}
      </span>
      <Dialog.Title class="dialog-title">{form.title}</Dialog.Title>
      <Dialog.Description class="dialog-description">
        {#if kind === "vault"}Your passwords will be encrypted on this device.
        {:else if kind === "cloud"}Save an encrypted copy of <strong>
            {vault}
          </strong> in your own storage.
        {:else}Keep a local copy of <strong>{vault}</strong> on this device.{/if}
      </Dialog.Description>
    </Dialog.Header>
    <form class="dialog-form" onsubmit={submit}>
      {#if kind === "device"}
        <div class="join-account">
          <Cloud aria-hidden="true" />
          <div><span>Sync account</span><strong>{account}</strong></div>
        </div>
      {/if}
      <div class="field">
        <label for="setup-value">{form.label}</label>
        <Input
          id="setup-value"
          class="setup-input rounded-none"
          bind:value
          bind:ref={input}
          type={kind === "cloud" ? "email" : "text"}
          inputmode={kind === "cloud" ? "email" : "text"}
          pattern={kind === "cloud" ? undefined : namePattern}
          title={kind === "cloud" ? undefined : "Enter a name"}
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
        <Button type="submit" class="confirm-action rounded-none">
          {form.submit}
        </Button>
      </Dialog.Footer>
    </form>
  </Dialog.Content>
</Dialog.Root>
