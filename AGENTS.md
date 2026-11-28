# UX guidance for Nook

For changes to the setup UI, copy, or artwork, follow the product model in the [README](README.md).

- **Open inside the product.** Show the visitor’s vaults and keyring from the first visit. Create the vault in the same workspace where it will be opened later. Keep the local vault available during device setup and restore the existing workspace on return.
- **Explain the outcome before the first input.** Someone seeing Nook for the first time should understand where their passwords will live, how they can use them offline, and whose cloud account syncs the encrypted copies. Keep the first action in reach for someone who already knows the product. [GOV.UK Design System — Start using a service](https://design-system.service.gov.uk/patterns/start-using-a-service/)
- **Use objects and words people recognize.** Start with passwords, this device, and the user’s own cloud account. Introduce the keyring as the devices that share a vault. Pair each change in the artwork with a visible label that explains what it means. [Nielsen Norman Group — Match Between the System and the Real World](https://www.nngroup.com/articles/match-system-real-world/)
- **Make progress readable.** Keep two setup steps. Create the vault locally, then link another device through the user’s cloud account. Show what is planned, what has happened, and the next action in text. On each transition, carry keyboard and screen-reader users to the updated step. [W3C WAI — Multi-page Forms](https://www.w3.org/WAI/tutorials/forms/multi-page/)

Review the untouched screen on a phone and desktop. A visitor should be able to trace this device ↔ their cloud account ↔ a second device from the objects and short labels alone. Put each setup action at the location it changes. Check that the artwork, connection, and accessible status update together when the action succeeds.
