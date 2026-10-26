# IT Lecturer Portfolio → Laravel (multi-user, admin CRUD)

Your static `index.html / style.css / script.js` converted into a Laravel 11/12 app.
Same design, but every text, card, project, skill… now comes from the database,
and every user gets their own portfolio at `/{username}`.

> This package contains **only the code that is specific to your app**
> (models, controllers, views, migrations, routes, CSS/JS). Laravel itself
> (`vendor/`, `artisan`, …) is downloaded by Composer in the install step.

## Requirements
PHP 8.2+, Composer, and the usual Laravel extensions (SQLite is the default DB; MySQL also works).

## Install (2 minutes)

**Linux / macOS / Git Bash**
```bash
bash install.sh my-portfolio
cd my-portfolio && php artisan serve
```

**Windows (cmd)**
```bat
install.bat my-portfolio
cd my-portfolio
php artisan serve
```

**Manual**
```bash
composer create-project laravel/laravel my-portfolio
# copy the folders app config database public resources routes from this package into my-portfolio (merge/overwrite)
cd my-portfolio
php artisan storage:link        # needed for profile photos
php artisan migrate --seed
php artisan serve
```

Open http://127.0.0.1:8000

## Default accounts (created by the seeder)
| Role  | Login                     | Password        |
|-------|---------------------------|-----------------|
| Admin | admin@example.com         | ChangeMe123!    |
| User  | natvannak@example.com     | ChangeMe123!    |

The second account holds your original portfolio (public at `/natvannak`).
**Change both passwords** (My account) — or set `PORTFOLIO_ADMIN_EMAIL` / `PORTFOLIO_ADMIN_PASSWORD` in `.env` *before* running `migrate --seed`.

## Features
* **Multi-user** – each user has a username and a public page `/{username}`; `/` shows a directory of published portfolios.
* **Roles** – `admin` (everything) and `user` (own portfolio only).
* **Admin full CRUD**
  * Users: create / edit / disable / delete, change role, reset password
  * “Manage content” lets an admin edit any user’s portfolio
* **User CRUD** for: hero stats, about cards, experience, skill categories, projects, research topics
  (add, edit, delete, display order) + profile texts, social links, photo upload.
* **Draft / publish** – a portfolio is hidden until its owner ticks *Publish*. Owner & admins can preview drafts.
* Dark/light theme toggle, responsive layout and reveal animations are unchanged.
* Security: CSRF on all forms, escaped output, hashed passwords, login throttling, ownership-scoped queries, URL validation (http/https only), image upload validation.

## Useful `.env` options
```
PORTFOLIO_DEFAULT_USER=natvannak   # show this portfolio at "/" instead of the directory
PORTFOLIO_ALLOW_REGISTRATION=true  # false = only admins can create users
```

## Where things are
| What | File |
|------|------|
| Public portfolio template (your original HTML) | `resources/views/portfolio.blade.php` |
| Styles / script (your originals) | `public/css/style.css`, `public/js/script.js` |
| Back-office | `resources/views/admin/**`, `public/css/admin.css` |
| Section definitions (fields & validation) | `app/Support/Sections.php` |
| Generic CRUD | `app/Http/Controllers/SectionController.php` |
| User management | `app/Http/Controllers/UserController.php` |
| Routes | `routes/web.php` |

Add a new section (e.g. *Publications*): create a migration + model, add a relation on `User`,
and add one entry to `Sections::all()` — the CRUD pages, routes and menu appear automatically
(then render it in `portfolio.blade.php`).

## Text formats used in the forms
* Bullets / paragraphs → one per line
* Skills / tags / code items → comma separated
* `**bold**` is supported in the About text
