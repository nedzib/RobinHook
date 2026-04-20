# AGENTS.md

## Stack And Wiring
- Rails 8.0 app on Ruby `3.3.7`; use Bundler and `bin/*` wrappers, not global gem commands.
- No Node package manifest is present. Frontend JS uses `importmap-rails` and Stimulus controllers under `app/javascript/controllers`; do not assume `npm`, `yarn`, or Vite.
- CSS is driven by `tailwindcss-rails`; local dev runs the watcher from `Procfile.dev`.
- Main app flow is `RoundController`: authenticated root is `root "round#index"`; public sharing is `GET /rounds/public?hash_id=...`.
- Reviewer selection logic lives in service objects, not controllers: `app/services/round_robin_sampler_service.rb`, `global_round_robin_sampler_service.rb`, and `webhook_notification_service.rb`.

## Dev Commands
- Initial setup: `bin/setup`.
- Local dev: `bin/dev`.
- `bin/dev` auto-installs `foreman` and starts `bin/rails server` plus `bin/rails tailwindcss:watch` from `Procfile.dev`.
- Database prep for local changes: `bin/rails db:prepare`.

## Verification
- Run the same checks CI runs before finishing work:
  1. `bin/rubocop -f github`
  2. `bin/brakeman --no-pager`
  3. `bin/importmap audit`
  4. `bin/rails db:test:prepare test test:system`
- Focused tests:
  1. Single file: `bin/rails test test/models/round_test.rb`
  2. Single test by line: `bin/rails test test/controllers/round_controller_test.rb:4`
- System tests use Selenium with headless Chrome (`test/application_system_test_case.rb`). CI installs Chrome explicitly, so local system tests need Chrome available too.
- Tests require PostgreSQL, not SQLite. Default local DB names come from `config/database.yml`: `robin_noob_development` and `robin_noob_test`.

## Repo-Specific Gotchas
- `dotenv-rails` is enabled only in development/test. Local env vars may come from `.env`, but production relies on real environment variables.
- The OpenAI client in `app/controllers/samplings_controller.rb` reads `ENV.fetch("OPENAPI_ACCESS_TOKEN")`. Do not “fix” this to a guessed variable name unless you are intentionally changing app behavior.
- Sampling requests skip Devise auth (`SamplingsController#create`), and public round pages skip auth too; preserve that behavior unless the task is explicitly about auth.
- Participant counter and availability UI updates come from `Participant` model callbacks broadcasting Turbo replacements. If you change counter/availability behavior, verify the broadcasted partial flow still works.
- In development, Action Cable uses the async adapter. `config/cable.yml` notes that manual cable testing must happen from the web console inside the dev process, not a separate `bin/rails console` terminal.

## Deployment / Production Notes
- Production uses PostgreSQL plus Rails 8 solid adapters: `solid_cache`, `solid_queue`, and `solid_cable`.
- `Dockerfile` is production-oriented only; it precompiles assets and starts via `./bin/thrust ./bin/rails server`.
- Kamal config in `config/deploy.yml` is still template-like (`your-user/robin_noob`, example hosts). Treat it as a starting point, not verified live deploy data.
