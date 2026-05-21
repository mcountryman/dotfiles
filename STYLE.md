# STYLE.md

## Typescript

### Ordering

Order functions highest-level to lowest-level. The default export comes first,
then the components it calls, then shared utilities. No section separator
comments.

```ts
// correct
export default function (...) { ... }

function renderThing(...) { ... }

function helper(...) { ... }
```

```ts
// wrong
/* ---- entry point ---- */
export default function (...) { ... }

/* ---- components ---- */
function renderThing(...) { ... }
```

---

### Naming

Prefer the domain term, not prefixes.

```ts
// correct
renderTopLeft(footer: FooterCtx, ...)

// wrong
renderTopLeft(fctx: FooterCtx, ...)
```

Short names when scope is clear.

```ts
// correct (inside renderBottomLeft)
const usage = ctx.getContextUsage();

// wrong
const contextUsage = ctx.getContextUsage();
```

Unused parameters use bare `_`, never `_name`.

```ts
// correct
function renderTopRight(footer: FooterCtx, _: number, theme: Theme): string {

// wrong
function renderTopRight(footer: FooterCtx, _width: number, theme: Theme): string {
```

---

### Variable placement

Destructure in the signature when only one field is used.

```ts
// correct
function renderBottomLeft({ ctx }: FooterCtx, _: number, theme: Theme): string {

// wrong
function renderBottomLeft(footer: FooterCtx, _: number, theme: Theme): string {
  const { ctx } = footer;
```

Hoist all declarations to the top of the function. `const` first, then `let`,
then logic. Compute dependent values once at the top — don't bury them inside
conditionals.

```ts
// correct
function renderBottomRight(footer: FooterCtx, _: number, theme: Theme): string {
  const { ctx, footerData, thinkingLevel } = footer;
  const level = thinkingLevel || "off";
  const modelName = ctx.model?.id || "no-model";

  let rightSide = modelName;

  if (ctx.model?.reasoning) {
    rightSide = level === "off"
      ? `${modelName} • thinking off`
      : `${modelName} • ${level}`;
  }

  // wrong
  if (ctx.model?.reasoning) {
    const level = thinkingLevel || "off";
    ...
  }
```

---

### Blank lines

Only between _phases_: **get → modify → return**. Never within a phase.

```ts
// correct — 3 phases, 2 blank lines
function renderTopLeft(footer: FooterCtx, _: number, theme: Theme): string {
  const { ctx, footerData } = footer;
  let pwd = ctx.sessionManager.getCwd();
  const home = process.env.HOME || process.env.USERPROFILE;
  const branch = footerData.getGitBranch();
  const sessionName = ctx.sessionManager.getSessionName();

  if (home && pwd.startsWith(home)) {
    pwd = `~${pwd.slice(home.length)}`;
  }
  if (branch) {
    pwd = `${pwd} (${branch})`;
  }
  if (sessionName) {
    pwd = `${pwd} • ${sessionName}`;
  }

  return theme.fg("dim", pwd);
}
```

```ts
// wrong — blank lines between individual declarations (same phase)
  let pwd = ...;
  const home = ...;

  const branch = ...;

  const sessionName = ...;
```

Guard clauses (early returns) are their own phase.

```ts
// correct
  const statuses = footer.footerData.getExtensionStatuses();
  if (statuses.size === 0) {
    return "";
  }

  const sorted = ...;
```

```ts
// wrong — guard separated from its return
const statuses = footer.footerData.getExtensionStatuses();

if (statuses.size === 0) {
  return "";
}
```

Multiple `if` blocks that mutate the same variable are one phase (no blanks
between them).

```ts
// correct
  if (ctx.model?.reasoning) {
    rightSide = ...;
  }
  if (footerData.getAvailableProviderCount() > 1 && ctx.model) {
    rightSide = ...;
  }

  return theme.fg("dim", rightSide);
```
