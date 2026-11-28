// GitHub Pages hosts the main app and its PRs on the same origin.
export const storageKey = "nook.keyring.v1:" + new URL("./", document.baseURI).pathname;

export function emptyWorkspace() {
  return { vault: "", account: "", device: "", example: false };
}

export function readWorkspace() {
  try {
    const saved = JSON.parse(localStorage.getItem(storageKey));
    if (typeof saved?.vault !== "string" || !saved.vault.trim()) return emptyWorkspace();
    const account = typeof saved.account === "string" ? saved.account.trim() : "";
    return {
      vault: saved.vault.trim(),
      account,
      device: account && typeof saved.device === "string" ? saved.device.trim() : "",
      example: saved.example === true,
    };
  } catch {
    return emptyWorkspace();
  }
}

export function writeWorkspace(workspace) {
  try {
    if (workspace.vault) localStorage.setItem(storageKey, JSON.stringify(workspace));
    else localStorage.removeItem(storageKey);
    return true;
  } catch {
    return false;
  }
}
