# Framework-Specific CLAUDE.md Snippets

When generating a project's `CLAUDE.md`, append the matching snippet(s) below to the **Conventions** or **Boundaries** section. Select based on the detected tech stack — a project may match multiple snippets (e.g. Next.js + Supabase + Stripe).

These snippets encode hard-won rules that prevent common agent mistakes in each framework. They're not generic best practices — they're the specific footguns that AI agents hit most often.

Inspired by real-world CLAUDE.md templates from everything-claude-code.

---

## Next.js (App Router)

```markdown
### Next.js conventions
- Use App Router (`app/`) — do not create pages in `pages/`
- Server Components are the default; add `'use client'` only when the component needs browser APIs, event handlers, or React state/effects
- Data fetching goes in Server Components or Route Handlers — never call `fetch` from Client Components to your own API routes (call the data source directly)
- Use `next/image` for all images — never raw `<img>` tags
- Use `next/link` for all internal navigation — never raw `<a>` tags
- Environment variables for the browser must be prefixed with `NEXT_PUBLIC_`
- Route Handlers go in `app/api/` using the `route.ts` convention
- Metadata goes in `layout.tsx` or `page.tsx` via the `metadata` export or `generateMetadata`
- Loading states use `loading.tsx`, errors use `error.tsx` (must be a Client Component)
```

## React (general)

```markdown
### React conventions
- Prefer function components with hooks — no class components
- Keep components under 200 lines; extract when a component does more than one thing
- Colocate component, styles, and tests: `Button/index.tsx`, `Button.module.css`, `Button.test.tsx`
- Never mutate state directly — always use the setter from `useState` or dispatch from `useReducer`
- Memoize expensive computations with `useMemo`; memoize callbacks passed to children with `useCallback`
- Side effects belong in `useEffect` — not in render logic or event handlers (unless intentional)
- Custom hooks must start with `use` and should extract reusable stateful logic — not just group functions
```

## Supabase

```markdown
### Supabase conventions
- Always use `createServerClient` for server-side operations, `createBrowserClient` for client-side
- Use `getUser()` for auth checks — NEVER `getSession()` (session can be spoofed from the client)
- Every table must have Row Level Security (RLS) enabled — no exceptions
- Use explicit column selects: `.select('id, name, email')` — never `.select('*')` in production
- Always add `.limit()` to queries that could return unbounded results
- Migrations go in `supabase/migrations/` — use `supabase migration new <name>` to create them
- Edge Functions go in `supabase/functions/` — test locally with `supabase functions serve`
- Never expose service_role key to the client — it bypasses RLS
```

## Stripe

```markdown
### Stripe conventions
- Never trust client-side price data — always fetch prices from Stripe on the server
- Webhook handlers must verify the signature using `stripe.webhooks.constructEvent`
- Use `stripe.checkout.sessions.create` for payment flows — don't build custom card forms unless required
- Store Stripe customer IDs in your user table — don't look up by email (emails change)
- Idempotency keys are required for all mutating API calls in production
- Test with Stripe CLI: `stripe listen --forward-to localhost:3000/api/webhooks/stripe`
- Use price IDs from Stripe dashboard, not hardcoded amounts
```

## Python (FastAPI)

```markdown
### FastAPI conventions
- Use Pydantic models for all request/response schemas — never raw dicts
- Use `Depends()` for dependency injection (database sessions, auth, config)
- Background tasks go in `BackgroundTasks` — not spawned threads
- Use `async def` for I/O-bound endpoints, regular `def` for CPU-bound (FastAPI handles both correctly)
- Exception handlers go in a central `exceptions.py` — don't scatter try/except across endpoints
- Use `lifespan` context manager for startup/shutdown logic (database pools, ML model loading)
- Always set `response_model` on endpoints — it validates outgoing data and generates OpenAPI docs
```

## Python (Django)

```markdown
### Django conventions
- Use class-based views for CRUD; function-based views for custom logic
- Models define the schema — never write raw SQL unless ORM can't express it
- Use `select_related` (FK) and `prefetch_related` (M2M) to prevent N+1 queries
- Migrations are source-controlled — never edit a migration that's been applied in production
- Settings split: `base.py` (shared), `development.py`, `production.py` — never `if DEBUG` in settings
- Use `django.contrib.auth` and extend `AbstractUser` — don't build custom auth from scratch
- URL patterns in `urls.py` — use `path()` with named URLs, never hardcode URLs in templates
- Static files go through `collectstatic` in production — don't serve from Django
```

## Go (microservices)

```markdown
### Go conventions
- No `init()` functions — they run before `main` and create hidden dependencies
- No global mutable state — pass dependencies explicitly through constructors or context
- Context is always the first parameter: `func DoThing(ctx context.Context, ...)`
- Errors are values — return them, don't panic. Use `fmt.Errorf("operation: %w", err)` for wrapping
- Define sentinel errors with `errors.New` for expected error conditions; use `errors.Is/As` for checking
- Table-driven tests: define test cases as a slice of structs, loop with `t.Run`
- Interfaces belong in the consumer package, not the provider — accept interfaces, return structs
- Use `defer` for cleanup (close files, release locks) — it runs even when the function panics
- No `else` after `return` — keep the happy path unindented (early return pattern)
```

## Go (gRPC)

```markdown
### gRPC conventions
- Proto files are the source of truth for API contracts — change the proto first, then regenerate
- Map domain errors to gRPC status codes: `codes.NotFound`, `codes.InvalidArgument`, `codes.Internal`
- Use interceptors for cross-cutting concerns (logging, auth, metrics) — not per-handler boilerplate
- Streaming RPCs must handle context cancellation: check `ctx.Done()` in loops
- Use `grpc-gateway` to expose REST endpoints from the same proto definitions
```

## Node.js / Express

```markdown
### Node.js conventions
- Use `async/await` for all asynchronous operations — never raw callbacks or `.then()` chains
- Error handling middleware goes last: `app.use((err, req, res, next) => { ... })`
- Never use `console.log` in production code — use a structured logger (pino, winston)
- Validate all request input with a schema library (zod, joi) at the route handler level
- Environment variables via `process.env` — always validate required vars at startup, not at first use
- Use `helmet()` middleware for security headers
- Close database connections and pending timers on SIGTERM for graceful shutdown
```

## TypeScript (general)

```markdown
### TypeScript conventions
- Enable `strict: true` in tsconfig — never weaken it to fix type errors (fix the code instead)
- Prefer `interface` for object shapes, `type` for unions and intersections
- No `any` — use `unknown` and narrow with type guards when the type truly isn't known
- Avoid `as` type assertions — they bypass the type checker. Use type narrowing or generics instead
- Enums should be `const enum` or string literal unions — avoid numeric enums (they're footguns)
- Export types separately from values: `export type { MyType }` (helps tree-shaking)
```

## Rust

```markdown
### Rust conventions
- Use `Result<T, E>` for fallible operations — `unwrap()` is only acceptable in tests
- Use the `?` operator for error propagation — no manual `.unwrap()` chains
- Derive `Debug`, `Clone`, `PartialEq` on domain types unless there's a reason not to
- Use `clippy` warnings as errors in CI: `cargo clippy -- -D warnings`
- Prefer `&str` over `String` in function parameters — accept the borrow, let the caller own
- Tests go in a `#[cfg(test)] mod tests` block inside the same file, not in a separate test file
- Use `cargo fmt` — no bikeshedding on formatting
```

## PHP / Laravel

```markdown
### Laravel conventions
- Use Eloquent for database access — no raw SQL unless the query can't be expressed in Eloquent
- Form Requests for validation: `php artisan make:request StoreUserRequest`
- Use `Route::resource` for CRUD — only define custom routes for non-CRUD actions
- Migrations are immutable once deployed — create a new migration to modify tables
- Use policies for authorization: `$this->authorize('update', $post)` in controllers
- Queue long-running operations: email sending, PDF generation, API calls to third parties
- Use config() helper, not env() outside of config files — env() doesn't work with cached config
- Blade components for reusable UI: `<x-alert type="danger">` not `@include`
```

## Database (PostgreSQL)

```markdown
### PostgreSQL conventions
- Always use parameterized queries — never string-concatenate user input into SQL
- Create indexes for columns used in WHERE, JOIN, and ORDER BY clauses
- Use transactions for multi-statement operations — don't assume autocommit is safe
- Foreign keys are mandatory for referential integrity — no "soft references" by convention
- Use `EXPLAIN ANALYZE` before and after adding indexes to verify they help
- Migrations must be reversible: every `CREATE` has a matching `DROP` in the down migration
- Use `BIGSERIAL` or `UUID` for primary keys — never `SERIAL` (32-bit overflow on large tables)
```

## CI/CD (GitHub Actions)

```markdown
### GitHub Actions conventions
- Pin action versions by SHA, not tag: `uses: actions/checkout@<sha>` (prevents supply-chain attacks)
- Cache dependencies: `actions/cache` for node_modules, pip cache, Go modules
- Fail fast on lint/typecheck before running the full test suite
- Use matrix strategy for testing across multiple versions/platforms
- Secrets go in GitHub Settings > Secrets — never in workflow files
- Use `concurrency` to cancel in-progress runs when a new push arrives on the same branch
```
