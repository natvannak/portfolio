<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{ config('app.name') }} — Portfolios</title>
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
</head>
<body>
  <header class="header">
    <nav class="nav container">
      <a href="{{ route('home') }}" class="logo">&lt;{{ config('app.name') }}<span>/&gt;</span></a>
      <div class="nav-actions">
        @auth
          <a class="btn secondary" href="{{ route('admin.dashboard') }}">Dashboard</a>
        @else
          <a class="btn secondary" href="{{ route('login') }}">Login</a>
          @if(config('portfolio.allow_registration'))
            <a class="btn primary" href="{{ route('register') }}">Create portfolio</a>
          @endif
        @endauth
        <button class="theme-btn" id="themeBtn" aria-label="Toggle theme">☾</button>
      </div>
    </nav>
  </header>

  <main class="container">
    <section class="dir-hero">
      <p class="eyebrow">PORTFOLIO DIRECTORY</p>
      <h1>People & their work.</h1>
      <p>Browse portfolios published on this site.</p>
    </section>

    @if($users->isEmpty())
      <p class="dir-empty">No portfolios have been published yet.</p>
    @else
      <div class="dir-grid">
        @foreach($users as $u)
          <a class="dir-card" href="{{ route('portfolio.show', ['username' => $u->username]) }}">
            <div class="avatar">
              <div class="avatar-ring"></div>
              @if($u->profile->avatar)
                <img src="{{ asset('storage/' . $u->profile->avatar) }}" alt="{{ $u->profile->full_name }}">
              @else
                <div class="avatar-initial">{{ $u->profile->initials() }}</div>
              @endif
            </div>
            <h3>{{ $u->profile->full_name }}</h3>
            <p>{{ $u->profile->role_title ?: '@' . $u->username }}</p>
          </a>
        @endforeach
      </div>
    @endif
  </main>

  <footer>
    <div class="container footer-inner">
      <span>© <span id="year">{{ date('Y') }}</span> {{ config('app.name') }}</span>
    </div>
  </footer>
  <script src="{{ asset('js/script.js') }}"></script>
</body>
</html>
