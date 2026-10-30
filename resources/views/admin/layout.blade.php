@php
  $me = auth()->user();
  $target = \App\Support\Portfolio::target();
  $managing = $target->id !== $me->id;
  $sectionList = \App\Support\Sections::all();
  $appInitial = mb_strtoupper(mb_substr(config('app.name'), 0, 1));
  $profile = $me->ensureProfile();
  $initial = mb_strtoupper(mb_substr($me->name, 0, 1));
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>@yield('title', 'Dashboard') — {{ config('app.name') }}</title>
  <link rel="stylesheet" href="{{ asset('css/style.css') }}">
  <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
</head>
<body class="admin">
  <div class="sidebar-backdrop" data-drawer-close></div>

  <aside class="sidebar" id="sidebar" aria-label="Admin navigation">
    <a href="{{ route('admin.dashboard') }}" class="logo">
      <span class="logo-mark">{{ $appInitial }}</span>
      <span>{{ config('app.name') }}<i class="logo-tail"> Admin</i></span>
    </a>

    <nav>
      <div class="nav-group">
        <p class="nav-label">Main</p>
        <a href="{{ route('admin.dashboard') }}" class="nav-item {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
          <x-icon name="dashboard" /> Dashboard
        </a>
        <a href="{{ route('admin.profile.edit') }}" class="nav-item {{ request()->routeIs('admin.profile.*') ? 'active' : '' }}">
          <x-icon name="user-round" /> Profile &amp; Texts
        </a>
      </div>

      <div class="nav-group">
        <p class="nav-label">Content management</p>
        @foreach($sectionList as $key => $cfg)
          <a href="{{ route('admin.section.index', ['section' => $key]) }}"
             class="nav-item {{ request()->is('admin/s/' . $key . '*') ? 'active' : '' }}">
            <x-icon name="{{ $cfg['icon'] }}" /> {{ $cfg['label'] }}
          </a>
        @endforeach
      </div>

      @if($me->isAdmin())
        <div class="nav-group">
          <p class="nav-label">Administration</p>
          <a href="{{ route('admin.users.index') }}" class="nav-item {{ request()->routeIs('admin.users.*') ? 'active' : '' }}">
            <x-icon name="users-round" /> Users
          </a>
        </div>
      @endif

      <div class="nav-group">
        <p class="nav-label">Account</p>
        <a href="{{ route('admin.account.edit') }}" class="nav-item {{ request()->routeIs('admin.account.*') ? 'active' : '' }}">
          <x-icon name="settings" /> My Account
        </a>
        @if($target->username)
          <a href="{{ route('portfolio.show', ['username' => $target->username]) }}" target="_blank" rel="noopener" class="nav-item">
            <x-icon name="external-link" /> View Portfolio
          </a>
        @endif
      </div>
    </nav>

    <div class="sidebar-foot">
      <div class="side-user">
        @if($profile->avatar)
          <img class="avatar-chip" src="{{ asset('storage/' . $profile->avatar) }}" alt="{{ $me->name }}">
        @else
          <span class="avatar-chip">{{ $initial }}</span>
        @endif
        <span class="who">
          <b>{{ $me->name }}</b>
          <small>&#64;{{ $me->username ?? $me->email }}</small>
        </span>
      </div>
      <form method="POST" action="{{ route('logout') }}">
        @csrf
        <button type="submit" class="sign-out"><x-icon name="log-out" :size="16" /> Sign out</button>
      </form>
    </div>
  </aside>

  <div class="main">
    <header class="mobile-bar">
      <button class="menu-btn" type="button" data-drawer-open aria-label="Open menu" aria-expanded="false">
        <x-icon name="menu" :size="18" />
      </button>
      <span class="bar-title">{{ config('app.name') }}<span> Admin</span></span>
    </header>

    @if($managing)
      <div class="manage-bar">
        <span><x-icon name="user-round" :size="14" style="margin-right:6px;vertical-align:-2px" /> Managing <b>{{ $target->name }}</b> (&#64;{{ $target->username }}) — changes affect their portfolio</span>
        <form method="POST" action="{{ route('admin.manage.stop') }}">@csrf <button class="btn" type="submit">Back to my own</button></form>
      </div>
    @endif

    <div class="content">
      @if(session('status'))
        <div class="alert ok"><x-icon name="circle-check" />{{ session('status') }}</div>
      @endif
      @if(session('error'))
        <div class="alert bad"><x-icon name="triangle-alert" />{{ session('error') }}</div>
      @endif
      @if($errors->any())
        <div class="alert bad"><x-icon name="triangle-alert" />Please fix the highlighted fields.</div>
      @endif

      @yield('content')
    </div>
  </div>

<script>
  /* Lightweight admin shell interactions: off-canvas drawer on tablet/mobile. */
  (function () {
    var body = document.body;
    var openBtn = document.querySelector('[data-drawer-open]');
    var sidebar = document.getElementById('sidebar');
    var closeEls = document.querySelectorAll('[data-drawer-close]');
    var close = function () { body.classList.remove('drawer-open'); if (openBtn) openBtn.setAttribute('aria-expanded', 'false'); };
    if (openBtn) openBtn.addEventListener('click', function () {
      var open = body.classList.toggle('drawer-open');
      openBtn.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
    closeEls.forEach(function (el) { el.addEventListener('click', close); });
    if (sidebar) {
      sidebar.addEventListener('click', function (e) {
        if (e.target.closest('a') && body.classList.contains('drawer-open')) close();
      });
    }
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') close(); });
  })();
</script>
</body>
</html>
