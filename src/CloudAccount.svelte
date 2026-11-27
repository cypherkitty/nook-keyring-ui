<script>
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import * as Dialog from "$lib/components/ui/dialog";
  import Cloud from "@lucide/svelte/icons/cloud";
  import CloudCheck from "@lucide/svelte/icons/cloud-check";

  let { account, vaultName, onConnect, focusNext } = $props();
  let open = $state(false);
  let email = $state("");
  let emailInput = $state(null);
  let confirmed = false;

  function prepareAccount(opening) {
    if (opening) {
      email = account || "you@example.com";
      confirmed = false;
    }
  }

  function connect(event) {
    event.preventDefault();
    confirmed = true;
    onConnect(email.trim());
    open = false;
  }

  function focusAccount(event) {
    event.preventDefault();
    emailInput?.focus();
    emailInput?.select();
  }

  function returnFocus(event) {
    if (confirmed) {
      event.preventDefault();
      focusNext();
    }
  }
</script>

<Dialog.Root bind:open onOpenChange={prepareAccount}>
  {#if account}
    <div class="account-receipt">
      <span class="row-icon"><CloudCheck aria-hidden="true" /></span>
      <div class="identity">
        <span class="small-label">Connected account</span>
        <strong>{account}</strong>
      </div>
      <Dialog.Trigger>
        {#snippet child({ props })}
          <Button
            {...props}
            variant="ghost"
            size="sm"
            class="change-action rounded-none"
            aria-label="Change cloud account"
          >
            Change
          </Button>
        {/snippet}
      </Dialog.Trigger>
    </div>
  {:else}
    <Dialog.Trigger>
      {#snippet child({ props })}
        <Button {...props} class="primary-action rounded-none">
          <Cloud aria-hidden="true" />Connect cloud account
        </Button>
      {/snippet}
    </Dialog.Trigger>
  {/if}

  <Dialog.Content
    class="account-dialog rounded-none"
    showCloseButton={false}
    onOpenAutoFocus={focusAccount}
    onCloseAutoFocus={returnFocus}
  >
    <Dialog.Header class="account-dialog-heading">
      <Dialog.Title class="dialog-title">
        Connect your cloud account
      </Dialog.Title>
      <Dialog.Description class="dialog-description">
        Sync an encrypted copy of <strong>{vaultName}</strong> to this account.
      </Dialog.Description>
    </Dialog.Header>
    <form class="account-form" onsubmit={connect}>
      <div class="field">
        <label for="account-email">Account email</label>
        <Input
          id="account-email"
          class="setup-input rounded-none"
          bind:value={email}
          bind:ref={emailInput}
          type="email"
          inputmode="email"
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
        <Button type="submit" class="connect-action rounded-none">
          Connect account
        </Button>
      </Dialog.Footer>
    </form>
  </Dialog.Content>
</Dialog.Root>
