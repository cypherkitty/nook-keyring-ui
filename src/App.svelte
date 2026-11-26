<script>
  import { tick } from "svelte";
  import {
    LayoutDashboard,
    Vault,
    KeyRound,
    Cloud,
    Monitor,
    BookOpen,
    ChevronRight,
    LockKeyhole,
    Plus,
    Link2,
    ShieldCheck,
    Menu,
    X,
    Fingerprint,
    Check,
    Eye,
    Copy,
    Layers3,
    CheckCheck,
    LockKeyholeOpen,
  } from "lucide-svelte";
  const nav = [
    { name: "Overview", icon: LayoutDashboard },
    { name: "My vault", icon: Vault },
    { name: "Keyring", icon: KeyRound },
    { name: "Sync provider", icon: Cloud },
  ];
  const descriptions = {
    Overview: "Your vault, devices, and sync at a glance.",
    "My vault": "Passwords and secrets stored on this device.",
    Keyring: "The devices with access to your vault.",
    "Sync provider": "Keep an encrypted copy with your storage provider.",
  };
  let page = $state("Overview"),
    mobileMenu = $state(false),
    modal = $state(""),
    dialog = $state(),
    created = $state(false),
    data = $state.raw(null),
    online = $state(false);
  let revealed = $state(false),
    notice = $state(""),
    selected = $state(null),
    search = $state("");
  let notifyTimer,
    linkStep = $state(1),
    deviceName = $state("Laptop"),
    demoItems = $state.raw([]),
    devices = $state.raw([]);
  const cards = $derived([
    {
      title: "Vault items",
      icon: Vault,
      value: created && !data ? "Locked" : String(data?.items.length || 0),
      sub: "Passwords and secrets",
      target: "My vault",
    },
    {
      title: "Keyring devices",
      icon: Monitor,
      value: created && !data ? "Locked" : String(data?.devices.length || 0),
      sub: "Devices linked to your vault",
      target: "Keyring",
    },
    {
      title: "Sync provider",
      icon: Cloud,
      value: online ? "Dropbox" : "Local only",
      sub: online ? "Demo provider connected" : "No provider connected",
      target: "Sync provider",
    },
  ]);
  const steps = $derived([
    {
      title: "Create your vault",
      copy: "Set up an encrypted home for your passwords.",
      icon: LockKeyhole,
      done: !!created,
      action: () => (created ? go("My vault") : open("create")),
    },
    {
      title: "Connect a sync provider",
      copy: "Use Dropbox to sync an encrypted copy.",
      icon: Cloud,
      done: online,
      action: () => go("Sync provider"),
    },
    {
      title: "Link another device",
      copy: "Add a trusted device to your keyring.",
      icon: Link2,
      done: devices.length > 1,
      action: () => open("link"),
    },
  ]);
  const complete = $derived(steps.filter((s) => s.done).length);
  const guide = [
    [
      "What is Nook?",
      "Nook keeps passwords and secrets together in an encrypted vault in this browser. Your master password unlocks the vault on your device.",
    ],
    [
      "What is a keyring?",
      "A keyring is the group of devices linked to one vault. Keeping a copy on another trusted device gives you another way to reach your secrets if you lose a device.",
    ],
    [
      "How do I add a device?",
      "Connect Dropbox on your first device and sync the vault. Open Nook on your new device, choose Link a device, and connect the same Dropbox account. Unlock the encrypted copy with your master password.",
    ],
    [
      "Where is my vault stored?",
      "This browser stores your encrypted vault locally. Clearing site data removes that copy. Connect a sync provider to keep a second copy you can open elsewhere.",
    ],
  ];
  let expanded = $state(0);
  function tell(message) {
    notice = message;
    clearTimeout(notifyTimer);
    notifyTimer = setTimeout(() => (notice = ""), 5500);
  }
  function go(next) {
    page = next;
    mobileMenu = false;
    search = "";
    window.scrollTo({ top: 0 });
  }
  function open(which) {
    mobileMenu = false;
    revealed = false;
    expanded = 0;
    linkStep = 1;
    deviceName = "Laptop";
    modal = which;
    tick().then(() => {
      if (dialog && !dialog.open) dialog.showModal();
    });
  }
  function close() {
    dialog?.close();
    modal = "";
    selected = null;
    revealed = false;
  }
  function lock() {
    data = null;
    close();
    tell("Demo vault locked.");
  }
  function showVault() {
    data = { name: "Personal vault", items: demoItems, devices };
    close();
    go("My vault");
  }
  function submitVault() {
    if (!created) {
      created = true;
      devices = [{ id: "local", name: "This browser" }];
    }
    showVault();
  }
  function addSample() {
    demoItems = [
      ...demoItems,
      {
        id: demoItems.length + 1,
        name: "Example login " + (demoItems.length + 1),
        username: "alex@example.com",
        password: "Example-password-123",
      },
    ];
    showVault();
    tell("Sample item added.");
  }
  function connect() {
    open("provider");
  }
  function finishLink() {
    if (!created) {
      created = true;
      devices = [{ id: "local", name: "This browser" }];
    }
    devices = [
      ...devices,
      {
        id: String(devices.length),
        name: deviceName.trim() || "Linked device",
      },
    ];
    data = { name: "Personal vault", items: demoItems, devices };
    close();
    go("Keyring");
    tell("Device linked in this demo.");
  }
</script>

<svelte:head><title>{page} · Nook</title></svelte:head>
{#if mobileMenu}<button
    class="scrim"
    aria-label="Close navigation"
    onclick={() => (mobileMenu = false)}
  ></button>{/if}
<aside class:shown={mobileMenu}>
  <button
    class="brand"
    onclick={() => go("Overview")}
    aria-label="Nook overview"
  >
    <img src="/nook.svg" alt="" />nook<span>.</span>
  </button>
  <div class="sidebar-group">WORKSPACE</div>
  <nav>
    {#each nav as entry}<button
        class:active={page === entry.name}
        aria-current={page === entry.name ? "page" : undefined}
        onclick={() => go(entry.name)}
      >
        <entry.icon size={18} />{entry.name}
      </button>{/each}
  </nav>
  <div class="sidebar-group resources">RESOURCES</div>
  <nav>
    <button onclick={() => open("guide")}>
      <BookOpen size={18} />Quick guide
    </button>
  </nav>
  <div class="side-bottom">
    <div class="device-icon"><Monitor size={19} /></div>
    <div><strong>This device</strong><small><i></i>Local workspace</small></div>
  </div>
</aside>
<div class="shell">
  <header>
    <div class="crumb">
      <button
        class="mobile-toggle"
        aria-label="Open navigation"
        onclick={() => (mobileMenu = true)}
      >
        <Menu size={20} />
      </button><Layers3 size={17} /><span>Workspace</span><span class="slash">
        /
      </span><b>{page}</b>
    </div>
    <button class="mode" onclick={() => go("Sync provider")}>
      <i></i>{online ? "Dropbox connected" : "Local mode"}
    </button>
  </header>
  <main>
    <div class="page-heading">
      <div>
        <h1>{page}</h1>
        <p>{descriptions[page]}</p>
      </div>
      {#if data}<button class="outline compact" onclick={lock}>
          <LockKeyhole size={15} />Lock vault
        </button>{/if}
    </div>
    {#if page === "Overview"}
      <section class="hero">
        <div class="hero-art" aria-hidden="true"></div>
        <div class="hero-copy">
          <span class="hero-tag">
            <ShieldCheck size={14} />LOCAL-FIRST PASSWORD MANAGER
          </span>
          <h2>Your secrets.<br /><em>Your devices.</em></h2>
          <p>
            Keep your passwords in an encrypted vault on your device. Link
            trusted devices when you’re ready.
          </p>
          <div class="actions">
            <button
              class="primary"
              onclick={() =>
                data ? go("My vault") : open(created ? "unlock" : "create")}
            >
              {#if created}<LockKeyholeOpen size={16} />{data
                  ? "Open vault"
                  : "Unlock vault"}{:else}<Plus size={17} />Create vault{/if}
            </button><button class="outline" onclick={() => open("link")}>
              <Link2 size={16} />Link a device
            </button>
          </div>
        </div>
      </section>
      <section class="overview-section">
        <h3>Workspace overview</h3>
        <div class="metrics">
          {#each cards as c}<button class="metric" onclick={() => go(c.target)}>
              <span class="metric-head">
                <span class="icon-tile"><c.icon size={17} /></span>{c.title}
              </span><strong class:word={c.value.length > 2}>
                {c.value}
              </strong><small>{c.sub}</small>
            </button>{/each}
        </div>
      </section>
      <section class="getting-started">
        <div class="section-head">
          <h3>Getting started</h3>
          <span class="progress">
            <span class="ticks">
              {#each steps as s}<i class:done={s.done}></i>{/each}
            </span>{complete} of 3 complete
          </span>
        </div>
        <div class="step-list">
          {#each steps as s}<button class="step" onclick={s.action}>
              <span class="step-icon">
                {#if s.done}<Check size={18} />{:else}<s.icon size={18} />{/if}
              </span><span class="step-copy">
                <b>{s.title}</b><small>{s.copy}</small>
              </span><ChevronRight class="chevron" size={16} />
            </button>{/each}
        </div>
      </section>
    {:else if page === "My vault"}
      {#if data}<div class="section-head">
          <h3>{data.name}</h3>
          <button class="primary" onclick={() => open("item")}>
            <Plus size={16} />Add item
          </button>
        </div>
        {#if data.items.length}<input
            class="search"
            aria-label="Search vault"
            placeholder="Search vault items…"
            bind:value={search}
          />
          <div class="step-list">
            {#each data.items.filter((i) => i.name
                .toLowerCase()
                .includes(search.toLowerCase())) as item}<button
                class="step"
                onclick={() => {
                  open("view");
                  selected = item;
                }}
              >
                <span class="step-icon"><KeyRound size={19} /></span><span
                  class="step-copy"
                >
                  <b>{item.name}</b><small>
                    {item.username || "Vault item"}
                  </small>
                </span><ChevronRight size={16} />
              </button>{:else}<p class="padded">No matching items.</p>{/each}
          </div>{:else}<div class="panel empty">
            <Vault />
            <h2>Your vault is ready</h2>
            <p>Add your first password or secret to this device.</p>
            <button class="primary" onclick={() => open("item")}>
              <Plus size={16} />Add first item
            </button>
          </div>{/if}
      {:else}<div class="panel empty">
          <Vault />
          <h2>
            {created ? "Your vault is locked" : "Create your local vault"}
          </h2>
          <p>
            {created
              ? "Open the demo vault to see your saved items."
              : "Keep passwords and secrets together on this device."}
          </p>
          <button
            class="primary"
            onclick={() => open(created ? "unlock" : "create")}
          >
            {created ? "Unlock vault" : "Create vault"}
          </button>
        </div>{/if}
    {:else if page === "Keyring"}
      <div class="panel">
        <div class="panel-top">
          <span class="large-icon"><KeyRound /></span>
          <div>
            <h2>Your keyring</h2>
            <p>
              Link trusted devices to keep another copy of your vault within
              reach.
            </p>
          </div>
        </div>
        {#if data}{#each data.devices as d}<div class="device-row">
              <Monitor size={19} /><strong>
                {d.name}
              </strong>{#if d.id === "local"}<span class="pill">
                  This device
                </span>{/if}
            </div>{/each}
        {:else}<p>
            {created
              ? "Unlock your vault to view its linked devices."
              : "Create a vault to start a keyring, or link this device to an existing one."}
          </p>{/if}
        <div class="actions">
          {#if !data}<button
              class="primary"
              onclick={() => open(created ? "unlock" : "create")}
            >
              {created ? "Unlock vault" : "Create vault"}
            </button>{/if}<button class="outline" onclick={() => open("link")}>
            <Link2 size={16} />Link a device
          </button>
        </div>
      </div>
    {:else}
      <div class="panel">
        <div class="panel-top">
          <span class="large-icon"><Cloud /></span>
          <div>
            <h2>Dropbox</h2>
            <p>Sync your encrypted vault through your own Dropbox account.</p>
          </div>
        </div>
        <p>
          {online
            ? "The demo provider is connected. You can now explore linking a device to your keyring."
            : "Connect the same account on each device to access one vault across your keyring."}
        </p>

        <button
          class="primary"
          onclick={() => (online ? open("link") : connect())}
        >
          {#if online}<Link2 size={16} />Link a device{:else}<Link2
              size={16}
            />Connect Dropbox{/if}
        </button>
      </div>
    {/if}
  </main>
</div>

{#if modal}
  <dialog
    aria-labelledby="modal-title"
    bind:this={dialog}
    oncancel={(e) => {
      e.preventDefault();
      close();
    }}
  >
    <div class="modal-top">
      <span class="large-icon">
        {#if modal === "guide"}<BookOpen />{:else if modal === "link"}<Link2
          />{:else}<Fingerprint />{/if}
      </span><button class="close" aria-label="Close dialog" onclick={close}>
        <X size={20} />
      </button>
    </div>
    {#if modal === "create" || modal === "unlock"}
      <h2 id="modal-title">
        {modal === "create" ? "Create your vault" : "Unlock your vault"}
      </h2>
      <p>
        {modal === "create"
          ? "Your vault starts on this device. Try a sample vault to explore how Nook keeps passwords and devices together."
          : "Open the sample vault to continue exploring your workspace."}
      </p>
      <div class="guide-rows">
        <div>
          <Vault /><span>
            <b>Personal vault</b><small>
              Interactive preview · Sample data only
            </small>
          </span>
        </div>
      </div>
      <button class="primary wide" onclick={submitVault}>
        {modal === "create" ? "Create demo vault" : "Unlock demo vault"}
      </button>
    {:else if modal === "link"}
      <h2 id="modal-title">Link a device</h2>
      {#if linkStep === 1}<p>
          Use your sync provider to bring a trusted device into the same
          keyring.
        </p>
        <div class="guide-rows">
          <div>
            <Cloud /><span>
              <b>Dropbox</b><small>
                Use the same Dropbox account on both devices so they can find
                your encrypted vault.
              </small>
            </span>
          </div>
        </div>
        <small>Interactive preview · No account required</small><button
          class="primary wide"
          onclick={() => {
            online = true;
            linkStep = 2;
          }}
        >
          Continue with Dropbox
        </button>
      {:else}<p>
          Your demo vault is ready to link. Choose a name to recognize this
          device in your keyring.
        </p>
        <form
          onsubmit={(e) => {
            e.preventDefault();
            finishLink();
          }}
        >
          <label>
            Device name<input required maxlength="60" bind:value={deviceName} />
          </label><button class="primary wide" disabled={!deviceName.trim()}>
            Link demo device
          </button>
        </form>{/if}
    {:else if modal === "provider"}<h2 id="modal-title">Connect Dropbox</h2>
      <p>
        Dropbox carries an encrypted copy between the devices in your keyring.
        Your vault stays available locally.
      </p>
      <div class="guide-rows">
        <div>
          <Cloud /><span>
            <b>Dropbox</b><small>
              Interactive preview · No account required
            </small>
          </span>
        </div>
      </div>
      <button
        class="primary wide"
        onclick={() => {
          online = true;
          close();
          tell("Demo sync provider connected.");
        }}
      >
        Connect demo provider
      </button>
    {:else if modal === "guide"}<h2 id="modal-title">Quick guide</h2>
      <p>Get to know your local-first workspace.</p>
      <div class="faq">
        {#each guide as g, i}<button
            aria-expanded={expanded === i}
            onclick={() => (expanded = expanded === i ? -1 : i)}
          >
            {g[0]}<ChevronRight
              class={expanded === i ? "rotated" : ""}
              size={16}
            />
          </button>{#if expanded === i}<p>{g[1]}</p>{/if}{/each}
      </div>
    {:else if modal === "item"}
      <h2 id="modal-title">Add a sample login</h2>
      <p>
        Preview how a saved password appears in your vault with a fictional
        account.
      </p>
      <div class="guide-rows">
        <div>
          <KeyRound /><span>
            <b>Example login {demoItems.length + 1}</b><small>
              alex@example.com
            </small>
          </span>
        </div>
      </div>
      <button class="primary wide" onclick={addSample}>Add sample item</button>
    {:else if modal === "view" && selected}
      <h2 id="modal-title">{selected.name}</h2>
      <label>
        Username<input readonly value={selected.username || "—"} />
      </label><label>
        Password or secret<input
          readonly
          type={revealed ? "text" : "password"}
          value={selected.password}
        />
      </label>
      <div class="actions">
        <button class="outline" onclick={() => (revealed = !revealed)}>
          <Eye size={16} />{revealed ? "Hide" : "Reveal"}
        </button><button
          class="primary"
          onclick={async () => {
            try {
              await navigator.clipboard.writeText(selected.password);
              tell("Sample password copied.");
            } catch {
              tell("Reveal the sample password to copy it.");
            }
          }}
        >
          <Copy size={16} />Copy
        </button>
      </div>
    {/if}
  </dialog>{/if}
{#if notice}<div class="toast" role="status">
    <CheckCheck size={17} />{notice}<button
      aria-label="Dismiss notification"
      onclick={() => (notice = "")}
    >
      <X size={15} />
    </button>
  </div>{/if}
