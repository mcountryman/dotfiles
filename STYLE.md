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

Avoid single-letter names and abbreviations even in tight scopes. Use the
full domain term.

```ts
// correct
const entry = ...;
const message = entry.message as AssistantMessage;

// wrong
const e = ...;
const m = e.message as AssistantMessage;
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

Hoist all declarations to the top of the function. Separate `const` and `let`
groups with a blank line. Compute dependent values once at the top — don't
bury them inside conditionals.

Mutable variables should be initialized when declared rather than left
`undefined`.

```ts
// correct
let thinkingLevel: string | undefined = pi.getThinkingLevel();

// wrong
let thinkingLevel: string | undefined;
```

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

Blank lines separate groups of statements of the same kind. A curly-brace
block (`if`, `for`, etc.) always gets a blank line after its closing brace.

**Declaration groups** are separated:

```ts
// correct
function renderBottomLeft(...): string {
  let totalInput = 0;
  let totalOutput = 0;

  const usage = ctx.getContextUsage();
  const parts: string[] = [];

  for (...) { ... }

  if (...) { ... }

  return ...;
}
```

**Independent conditional blocks** are separated:

```ts
// correct
  if (totalInput) {
    parts.push(`↑${formatTokens(totalInput)}`);
  }

  if (totalOutput) {
    parts.push(`↓${formatTokens(totalOutput)}`);
  }

  if (totalCost) {
    parts.push(`$${totalCost.toFixed(3)}`);
  }
```

```ts
// wrong — independent conditionals jammed together
  if (totalInput) {
    parts.push(`↑${formatTokens(totalInput)}`);
  }
  if (totalOutput) {
    parts.push(`↓${formatTokens(totalOutput)}`);
  }
```

**Independent side-effect registrations** are separated:

```ts
// correct
  pi.on("thinking_level_select", async (event) => {
    thinkingLevel = event.level;
  });

  pi.on("session_start", async (_event, ctx) => {
    ...
  });
```

**Compute-then-return within a block** is separated:

```ts
// correct
  if (leftWidth + 2 + rightWidth <= width) {
    const padding = " ".repeat(width - leftWidth - rightWidth);

    return left + padding + right;
  }
```

**Guard clauses** (early returns) are followed by a blank line:

```ts
// correct
  const statuses = footerData.getExtensionStatuses();
  if (statuses.size === 0) {
    return "";
  }

  const sorted = ...;
```

```ts
// wrong — blank line between guard declaration and its return
const statuses = footerData.getExtensionStatuses();

if (statuses.size === 0) {
  return "";
}
```
